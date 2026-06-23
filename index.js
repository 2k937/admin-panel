const { 
  Client, 
  GatewayIntentBits, 
  Partials, 
  EmbedBuilder, 
  ActionRowBuilder, 
  StringSelectMenuBuilder, 
  ButtonBuilder, 
  ButtonStyle,
  ComponentType,
  PermissionFlagsBits,
  ChannelType,
  OverwriteType
} = require('discord.js');
const fs = require('fs');
const dotenv = require('dotenv');

dotenv.config();

const GROQ_API_KEY = process.env.GROQ_API_KEY;

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMembers,
    GatewayIntentBits.GuildModeration,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.DirectMessages,
  ],
  partials: [Partials.Channel],
});

const PREFIX = ':';

// Multiple developer user IDs from .env (comma-separated)
const DEVELOPER_IDS = process.env.DEVELOPER_IDS ? process.env.DEVELOPER_IDS.split(',').map(id => id.trim()).filter(Boolean) : [];
let MOD_ROLES = []; // Array of role IDs for moderators

const WARNINGS_FILE = 'warnings.json';
const CONFIG_FILE = 'config.json';
const ECONOMY_FILE = 'economy.json';

// Load warnings
let warnings = {};
if (fs.existsSync(WARNINGS_FILE)) {
  try {
    warnings = JSON.parse(fs.readFileSync(WARNINGS_FILE, 'utf8'));
  } catch (e) {
    console.error("Error parsing warnings file, resetting to empty.");
    warnings = {};
  }
} else {
  fs.writeFileSync(WARNINGS_FILE, JSON.stringify({}, null, 2));
}

// Load config (for jail settings)
let config = { jail_role: null, jail_channel: null };
if (fs.existsSync(CONFIG_FILE)) {
  try {
    config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
  } catch (e) {
    console.error("Error parsing config file, resetting to default.");
    config = { jail_role: null, jail_channel: null };
  }
} else {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
}

// Load economy data
let economy = {};
if (fs.existsSync(ECONOMY_FILE)) {
  try {
    economy = JSON.parse(fs.readFileSync(ECONOMY_FILE, 'utf8'));
  } catch (e) {
    console.error("Error parsing economy file, resetting to empty.");
    economy = {};
  }
} else {
  fs.writeFileSync(ECONOMY_FILE, JSON.stringify({}, null, 2));
}

// Save warnings
function saveWarnings() {
  fs.writeFileSync(WARNINGS_FILE, JSON.stringify(warnings, null, 2));
}

// Save config
function saveConfig() {
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
}

// Save economy
function saveEconomy() {
  fs.writeFileSync(ECONOMY_FILE, JSON.stringify(economy, null, 2));
}

// Economy Helpers
function getBalance(userId) {
  if (!economy[userId]) {
    economy[userId] = { balance: 0, bank: 0, lastDaily: 0, lastWork: 0 };
    saveEconomy();
  }
  return economy[userId];
}

function updateBalance(userId, amount) {
  const user = getBalance(userId);
  user.balance += amount;
  saveEconomy();
  return user.balance;
}

// Check if user has permission
function hasModPermission(member) {
  if (!member) return false;
  if (DEVELOPER_IDS.includes(member.id)) return true;
  if (member.permissions.has(PermissionFlagsBits.ModerateMembers)) return true;
  return MOD_ROLES.some(roleId => member.roles.cache.has(roleId));
}

// Check if user is developer
function isDeveloper(userId) {
  return DEVELOPER_IDS.includes(userId);
}

// Safety check
function canModerate(modMember, targetMember) {
  if (!modMember || !targetMember) return false;
  if (modMember.id === targetMember.id) return false;
  if (isDeveloper(modMember.id)) return true;
  if (targetMember.id === client.user.id) return false;
  return modMember.roles.highest.comparePositionTo(targetMember.roles.highest) > 0;
}

// DM user
async function sendDM(user, content) {
  try {
    await user.send(content);
  } catch (e) {
    console.log(`Could not DM user ${user.id}`);
  }
}

// Helper for readable embeds
function createEmbed(title, description, color = 'Blue') {
    return new EmbedBuilder()
        .setTitle(title)
        .setDescription(description)
        .setColor(color)
        .setTimestamp()
        .setFooter({ text: 'Bot System', iconURL: client.user.displayAvatarURL() });
}

client.once('ready', () => {
  console.log(`Bot is ready! Logged in as ${client.user.tag}`);

  // Rotating statuses
  const statuses = [
    "managing members",
    "staff actions",
    "ban appeals",
    "server safety",
    "moderation logs",
    "gambling mini-games",
    "economy system"
  ];

  let i = 0;
  setInterval(() => {
    const status = statuses[i];
    client.user.setActivity(status, { type: 3 }); // Watching
    i = (i + 1) % statuses.length;
  }, 60000);
});

client.on('messageCreate', async message => {
  if (message.author.bot || !message.guild) return;

  // AI Auto-Moderation
  if (!hasModPermission(message.member) && message.content.length > 0) {
    try {
        const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${GROQ_API_KEY}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                model: "llama-3.3-70b-versatile",
                messages: [
                    {
                        role: "system",
                        content: "You are a content moderator. Analyze the message for extreme toxicity, slurs, or highly inappropriate behavior. If the message contains slurs or is extremely inappropriate, respond with 'BAN'. Otherwise, respond with 'PASS'. Do not provide any other text."
                    },
                    { role: "user", content: message.content }
                ],
                temperature: 0,
                max_tokens: 5
            })
        });

        const data = await response.json();
        const result = data.choices[0].message.content.trim();

        if (result.includes('BAN')) {
            const banReason = "AI Moderation: Use of slurs or extreme inappropriate behavior.";
            const dmEmbed = createEmbed('⚠️ Banned', `You have been banned from **${message.guild.name}** for violating our community guidelines (slurs/extreme behavior).`, 'Red');
            
            await sendDM(message.author, { embeds: [dmEmbed] });
            await message.delete().catch(() => {});
            await message.guild.members.ban(message.author.id, { reason: banReason });
            
            return message.channel.send({ embeds: [createEmbed('AI Auto-Mod', `Banned **${message.author.tag}** for slurs/extreme inappropriate behavior.`, 'Red')] });
        }
    } catch (e) {
        console.error("AI Moderation Error:", e);
    }
  }

  if (!message.content.startsWith(PREFIX)) return;

  const args = message.content.slice(PREFIX.length).trim().split(/ +/);
  const command = args.shift().toLowerCase();
  const member = message.member;

  // Command categories
  const modCmds = ['warn', 'warnings', 'clearwarns', 'kick', 'ban', 'tempban', 'softban', 'mute', 'timeout', 'unmute', 'unban', 'requestban', 'softbans', 'jail', 'unjail', 'lock', 'unlock', 'purge', 'slowmode'];
  const devCmds = ['modrole', 'eval', 'restart', 'stats', 'servers', 'jailsetup', 'maintenance', 'leaveserver', 'broadcast', 'setstatus', 'guilds', 'nuke', 'tempadmin', 'untempadmin', 'givemoney', 'resetmoney'];
  const funCmds = ['coinflip', 'roll', 'meme', 'fact', 'slots', 'blackjack', 'gamble'];
  const economyCmds = ['balance', 'bal', 'daily', 'work', 'pay', 'deposit', 'dep', 'withdraw', 'with'];

  const isModCmd = modCmds.includes(command);
  const isDevCmd = devCmds.includes(command);
  const isFunCmd = funCmds.includes(command);
  const isEconomyCmd = economyCmds.includes(command);

  if (isModCmd && !hasModPermission(member)) {
    return message.reply({ embeds: [createEmbed('Permission Denied', 'You do not have permission to use moderation commands.', 'Red')] });
  }

  // Specific permission checks
  if (['ban', 'softban', 'tempban', 'unban'].includes(command)) {
    if (!member.permissions.has(PermissionFlagsBits.BanMembers) && !isDeveloper(message.author.id)) {
        return message.reply({ embeds: [createEmbed('Permission Denied', 'You need the **Ban Members** permission to use this command.', 'Red')] });
    }
  }

  if (command === 'kick') {
    if (!member.permissions.has(PermissionFlagsBits.KickMembers) && !isDeveloper(message.author.id)) {
        return message.reply({ embeds: [createEmbed('Permission Denied', 'You need the **Kick Members** permission to use this command.', 'Red')] });
    }
  }

  if (isDevCmd && !isDeveloper(message.author.id)) {
    return message.reply({ embeds: [createEmbed('Permission Denied', 'This command is restricted to developers only.', 'Red')] });
  }

  // Target resolution (mention or ID)
  let target = message.mentions.members.first();
  let idUsed = false;
  if (!target && args[0]) {
    const possibleId = args[0].replace(/[<@!>]/g, '').trim();
    if (possibleId.length >= 17) {
        target = await message.guild.members.fetch(possibleId).catch(() => null);
        idUsed = true;
    }
  }

  // If we have a target, the reason starts from args[1]
  const reason = (target || idUsed) ? args.slice(1).join(' ') || 'No reason provided' : args.join(' ') || 'No reason provided';

  // Hierarchy check for mod commands
  const hierarchyCommands = ['warn', 'kick', 'ban', 'tempban', 'softban', 'mute', 'timeout', 'unmute', 'jail', 'unjail'];
  if (hierarchyCommands.includes(command) && target) {
    if (!canModerate(member, target)) {
      return message.reply({ embeds: [createEmbed('Hierarchy Error', 'You cannot moderate this user due to role hierarchy.', 'Red')] });
    }
  }

  switch (command) {
    // --- General Commands ---
    case 'ping':
      message.reply({ embeds: [createEmbed('🏓 Pong!', `Latency: **${Math.round(client.ws.ping)}ms**`, 'Green')] });
      break;

    case 'help':
      const helpEmbed = createEmbed('Bot Help Menu', 'Select a category from the dropdown below to view commands.');
      const helpOptions = [
        { label: 'General', description: 'Basic commands for everyone', value: 'help_general', emoji: '🌐' },
        { label: 'Economy', description: 'Money and earnings', value: 'help_economy', emoji: '💰' },
        { label: 'Fun & Gambling', description: 'Games and entertainment', value: 'help_fun', emoji: '🎮' },
        { label: 'Moderation', description: 'Staff moderation tools', value: 'help_mod', emoji: '🛡️' }
      ];

      if (isDeveloper(message.author.id)) {
        helpOptions.push({ label: 'Developer', description: 'Owner only commands', value: 'help_dev', emoji: '💻' });
      }

      const helpRow = new ActionRowBuilder().addComponents(
        new StringSelectMenuBuilder()
          .setCustomId('help_menu')
          .setPlaceholder('Select a category')
          .addOptions(helpOptions)
      );

      message.reply({ embeds: [helpEmbed], components: [helpRow] });
      break;

    // --- Economy Commands ---
    case 'bal':
    case 'balance':
        const balTarget = target || message.member;
        const balData = getBalance(balTarget.id);
        const balEmbed = createEmbed(`${balTarget.user.username}'s Balance`, `**Wallet:** $${balData.balance.toLocaleString()}\n**Bank:** $${balData.bank.toLocaleString()}\n**Total:** $${(balData.balance + balData.bank).toLocaleString()}`, 'Gold');
        message.reply({ embeds: [balEmbed] });
        break;

    case 'daily':
        const dailyUser = getBalance(message.author.id);
        const now = Date.now();
        const cooldown = 24 * 60 * 60 * 1000;
        if (now - dailyUser.lastDaily < cooldown) {
            const remaining = cooldown - (now - dailyUser.lastDaily);
            const hours = Math.floor(remaining / (60 * 60 * 1000));
            const minutes = Math.floor((remaining % (60 * 60 * 1000)) / (60 * 1000));
            return message.reply(`You've already claimed your daily reward! Come back in **${hours}h ${minutes}m**.`);
        }
        const dailyAmount = 500;
        dailyUser.balance += dailyAmount;
        dailyUser.lastDaily = now;
        saveEconomy();
        message.reply({ embeds: [createEmbed('Daily Reward', `You claimed your daily reward of **$${dailyAmount}**!`, 'Green')] });
        break;

    case 'work':
        const workUser = getBalance(message.author.id);
        const workNow = Date.now();
        const workCooldown = 60 * 60 * 1000; // 1 hour
        if (workNow - workUser.lastWork < workCooldown) {
            const remaining = workCooldown - (workNow - workUser.lastWork);
            const minutes = Math.floor(remaining / (60 * 1000));
            const seconds = Math.floor((remaining % (60 * 1000)) / 1000);
            return message.reply(`You're too tired! Work again in **${minutes}m ${seconds}s**.`);
        }
        const jobs = ['Programmer', 'Doctor', 'Chef', 'Artist', 'Streamer', 'Janitor'];
        const job = jobs[Math.floor(Math.random() * jobs.length)];
        const workAmount = Math.floor(Math.random() * 200) + 50;
        workUser.balance += workAmount;
        workUser.lastWork = workNow;
        saveEconomy();
        message.reply({ embeds: [createEmbed('Work', `You worked as a **${job}** and earned **$${workAmount}**!`, 'Blue')] });
        break;

    case 'dep':
    case 'deposit':
        let depAmount = args[0];
        const depUser = getBalance(message.author.id);
        if (!depAmount) return message.reply('Specify an amount to deposit.');
        if (depAmount.toLowerCase() === 'all') depAmount = depUser.balance;
        depAmount = parseInt(depAmount);
        if (isNaN(depAmount) || depAmount <= 0) return message.reply('Invalid amount.');
        if (depUser.balance < depAmount) return message.reply('You don\'t have enough money in your wallet.');
        depUser.balance -= depAmount;
        depUser.bank += depAmount;
        saveEconomy();
        message.reply(`Successfully deposited **$${depAmount}** into your bank.`);
        break;

    case 'with':
    case 'withdraw':
        let withAmount = args[0];
        const withUser = getBalance(message.author.id);
        if (!withAmount) return message.reply('Specify an amount to withdraw.');
        if (withAmount.toLowerCase() === 'all') withAmount = withUser.bank;
        withAmount = parseInt(withAmount);
        if (isNaN(withAmount) || withAmount <= 0) return message.reply('Invalid amount.');
        if (withUser.bank < withAmount) return message.reply('You don\'t have enough money in your bank.');
        withUser.bank -= withAmount;
        withUser.balance += withAmount;
        saveEconomy();
        message.reply(`Successfully withdrew **$${withAmount}** from your bank.`);
        break;

    case 'pay':
        if (!target) return message.reply('Mention someone to pay.');
        let payAmount = parseInt(args[1]);
        if (isNaN(payAmount) || payAmount <= 0) return message.reply('Invalid amount.');
        const sender = getBalance(message.author.id);
        if (sender.balance < payAmount) return message.reply('You don\'t have enough money in your wallet.');
        const receiver = getBalance(target.id);
        sender.balance -= payAmount;
        receiver.balance += payAmount;
        saveEconomy();
        message.reply(`You paid **$${payAmount}** to ${target.user.tag}.`);
        break;

    // --- Gambling Commands ---
    case 'gamble':
        let bet = args[0];
        const gUser = getBalance(message.author.id);
        if (!bet) return message.reply('Specify a bet amount.');
        if (bet.toLowerCase() === 'all') bet = gUser.balance;
        bet = parseInt(bet);
        if (isNaN(bet) || bet <= 0) return message.reply('Invalid bet.');
        if (gUser.balance < bet) return message.reply('You don\'t have enough money.');

        const userRoll = Math.floor(Math.random() * 100) + 1;
        const botRoll = Math.floor(Math.random() * 100) + 1;

        if (userRoll > botRoll) {
            gUser.balance += bet;
            message.reply({ embeds: [createEmbed('Gambling Win', `You rolled **${userRoll}** and I rolled **${botRoll}**.\nYou won **$${bet}**!`, 'Green')] });
        } else if (userRoll < botRoll) {
            gUser.balance -= bet;
            message.reply({ embeds: [createEmbed('Gambling Loss', `You rolled **${userRoll}** and I rolled **${botRoll}**.\nYou lost **$${bet}**.`, 'Red')] });
        } else {
            message.reply({ embeds: [createEmbed('Gambling Tie', `We both rolled **${userRoll}**. It's a tie!`, 'Grey')] });
        }
        saveEconomy();
        break;

    case 'slots':
        let sBet = parseInt(args[0]);
        const sUser = getBalance(message.author.id);
        if (isNaN(sBet) || sBet <= 0) return message.reply('Specify a valid bet amount.');
        if (sUser.balance < sBet) return message.reply('You don\'t have enough money.');

        const emojis = ['🍒', '🍋', '🍇', '💎', '🔔'];
        const slot1 = emojis[Math.floor(Math.random() * emojis.length)];
        const slot2 = emojis[Math.floor(Math.random() * emojis.length)];
        const slot3 = emojis[Math.floor(Math.random() * emojis.length)];

        let sResult = `[ ${slot1} | ${slot2} | ${slot3} ]\n\n`;
        if (slot1 === slot2 && slot2 === slot3) {
            const win = sBet * 5;
            sUser.balance += win;
            sResult += `JACKPOT! You won **$${win}**!`;
            message.reply({ embeds: [createEmbed('Slots', sResult, 'Green')] });
        } else if (slot1 === slot2 || slot2 === slot3 || slot1 === slot3) {
            const win = sBet * 2;
            sUser.balance += win;
            sResult += `Nice! You won **$${win}**!`;
            message.reply({ embeds: [createEmbed('Slots', sResult, 'Yellow')] });
        } else {
            sUser.balance -= sBet;
            sResult += `Better luck next time. You lost **$${sBet}**.`;
            message.reply({ embeds: [createEmbed('Slots', sResult, 'Red')] });
        }
        saveEconomy();
        break;

    // --- Moderation Commands ---
    case 'lock':
        await message.channel.permissionOverwrites.edit(message.guild.id, { SendMessages: false });
        message.reply({ embeds: [createEmbed('Channel Locked', `This channel has been locked by ${message.author.tag}.`, 'Orange')] });
        break;

    case 'unlock':
        await message.channel.permissionOverwrites.edit(message.guild.id, { SendMessages: null });
        message.reply({ embeds: [createEmbed('Channel Unlocked', `This channel has been unlocked by ${message.author.tag}.`, 'Green')] });
        break;

    case 'purge':
        const amount = parseInt(args[0]);
        if (isNaN(amount) || amount < 1 || amount > 100) return message.reply('Please provide a number between 1 and 100.');
        await message.channel.bulkDelete(amount, true);
        message.channel.send({ embeds: [createEmbed('Purge Complete', `Deleted ${amount} messages.`, 'Green')] }).then(m => setTimeout(() => m.delete(), 5000));
        break;

    case 'slowmode':
        const seconds = parseInt(args[0]);
        if (isNaN(seconds)) return message.reply('Please provide a valid number of seconds.');
        await message.channel.setRateLimitPerUser(seconds);
        message.reply({ embeds: [createEmbed('Slowmode Updated', `Slowmode has been set to ${seconds} seconds.`, 'Blue')] });
        break;

    case 'jail':
        if (!target) return message.reply('Please mention a user to jail.');
        if (!config.jail_role) return message.reply('Jail system is not set up. Use `:jailsetup`.');
        try {
            await target.roles.add(config.jail_role);
            message.reply({ embeds: [createEmbed('User Jailed', `Successfully jailed ${target.user.tag}.`, 'Orange')] });
            if (config.jail_channel) {
                const jailChannel = message.guild.channels.cache.get(config.jail_channel);
                if (jailChannel) jailChannel.send({ embeds: [createEmbed('Jail Log', `User: ${target.user.tag}\nModerator: ${message.author.tag}\nReason: ${reason}`, '#000000')] });
            }
        } catch (e) { message.reply(`Error: ${e.message}`); }
        break;

    case 'unjail':
        if (!target) return message.reply('Please mention a user to unjail.');
        if (!config.jail_role) return message.reply('Jail system is not set up.');
        try {
            await target.roles.remove(config.jail_role);
            message.reply({ embeds: [createEmbed('User Unjailed', `Successfully unjailed ${target.user.tag}.`, 'Green')] });
        } catch (e) { message.reply(`Error: ${e.message}`); }
        break;

    case 'warn':
      if (!target) return message.reply('Please mention a user to warn.');
      if (!warnings[target.id]) warnings[target.id] = [];
      warnings[target.id].push({ reason, moderator: message.author.tag, timestamp: new Date().toISOString() });
      saveWarnings();

      const warnCount = warnings[target.id].length;
      let punishmentType = '';

      // Auto-punishment logic
      try {
          if (warnCount === 3) {
              punishmentType = '5-hour timeout';
              await target.timeout(5 * 60 * 60 * 1000, 'Automatic punishment: 3 warnings');
          } else if (warnCount === 5) {
              punishmentType = 'Kick';
              await target.kick('Automatic punishment: 5 warnings');
          } else if (warnCount === 7) {
              punishmentType = '7-day Temp-ban';
              await message.guild.bans.create(target.id, { reason: 'Automatic punishment: 7 warnings' });
          } else if (warnCount >= 8) {
              punishmentType = 'Permanent Ban';
              await message.guild.bans.create(target.id, { reason: 'Automatic punishment: 8+ warnings' });
          }

          if (punishmentType) {
              const automodEmbed = createEmbed('⚠️ AutoMod Action', `You have been actioned by **AutoMod** in **${message.guild.name}**.`, 'Red');
              automodEmbed.addFields(
                  { name: 'Action', value: punishmentType, inline: true },
                  { name: 'Reason', value: `Accumulated ${warnCount} warnings.`, inline: true }
              );
              await sendDM(target.user, { embeds: [automodEmbed] });
          }
      } catch (e) {
          console.error(`Failed to apply auto-punishment: ${e.message}`);
      }

      const warnEmbed = createEmbed('Warning Issued', `You have been warned in ${message.guild.name}\nReason: ${reason}\nTotal Warnings: ${warnCount}`, 'Yellow');
      await sendDM(target.user, { embeds: [warnEmbed] });
      message.reply({ embeds: [createEmbed('Warning Issued', `Warned ${target.user.tag}. (Total: ${warnCount})${punishmentType ? `\n**AutoMod Action:** ${punishmentType}` : ''}`, 'Yellow')] });
      break;

    case 'warnings':
      if (!target) return message.reply('Please mention a user.');
      const userWarnings = warnings[target.id] || [];
      const warnListEmbed = createEmbed(`Warnings for ${target.user.tag}`, userWarnings.length === 0 ? 'No warnings.' : '', 'Blue');
      if (userWarnings.length === 0) return message.reply({ embeds: [warnListEmbed] });

      userWarnings.forEach((w, i) => {
        warnListEmbed.addFields({ name: `Warning #${i + 1}`, value: `Reason: ${w.reason}\nModerator: ${w.moderator}\nDate: ${new Date(w.timestamp).toLocaleDateString()}` });
      });

      const warnRow = new ActionRowBuilder().addComponents(
        new StringSelectMenuBuilder()
          .setCustomId('delete_warning')
          .setPlaceholder('Select a warning to delete')
          .addOptions(userWarnings.map((w, i) => ({ label: `Warning #${i + 1}`, value: `${target.id}_${i}` })))
      );

      message.reply({ embeds: [warnListEmbed], components: [warnRow] });
      break;

    case 'clearwarns':
      if (!target) return message.reply('Please mention a user.');
      delete warnings[target.id];
      saveWarnings();
      message.reply({ embeds: [createEmbed('Warnings Cleared', `Cleared all warnings for ${target.user.tag}.`, 'Green')] });
      break;

    case 'kick':
      if (!target) return message.reply('Please mention a user to kick.');
      await target.kick(reason);
      message.reply({ embeds: [createEmbed('User Kicked', `Kicked ${target.user.tag}\nReason: ${reason}`, 'Orange')] });
      break;

    case 'ban':
      if (!target) return message.reply('Please mention a user to ban.');
      await target.ban({ reason });
      message.reply({ embeds: [createEmbed('User Banned', `Banned ${target.user.tag}\nReason: ${reason}`, 'Red')] });
      break;

    case 'tempban':
      if (!target) return message.reply('Please mention a user.');
      const duration = args[1];
      const ms = parseDuration(duration);
      if (!ms) return message.reply('Invalid duration. Use: 10m, 1h, 1d');
      await target.ban({ reason });
      message.reply({ embeds: [createEmbed('Temp-Ban Issued', `Banned ${target.user.tag} for ${duration}.\nReason: ${reason}`, 'Red')] });
      setTimeout(async () => {
        await message.guild.members.unban(target.id).catch(() => {});
      }, ms);
      break;

    case 'mute':
    case 'timeout':
      if (!target) return message.reply('Please mention a user.');
      const tDuration = args[1];
      const tMs = parseDuration(tDuration);
      if (!tMs) return message.reply('Invalid duration. Use: 10m, 1h, 1d');
      await target.timeout(tMs, reason);
      message.reply({ embeds: [createEmbed('User Muted', `Muted ${target.user.tag} for ${tDuration}.\nReason: ${reason}`, 'Grey')] });
      break;

    case 'unmute':
      if (!target) return message.reply('Please mention a user.');
      await target.timeout(null);
      message.reply({ embeds: [createEmbed('User Unmuted', `Unmuted ${target.user.tag}.`, 'Green')] });
      break;

    case 'unban':
      const unbanId = args[0];
      if (!unbanId) return message.reply('Please provide a user ID.');
      await message.guild.members.unban(unbanId);
      message.reply({ embeds: [createEmbed('User Unbanned', `Unbanned ID: ${unbanId}`, 'Green')] });
      break;

    case 'requestban':
        if (!target) return message.reply('Mention a user to request a ban for.');
        const requestEmbed = createEmbed('Ban Request', `**Target:** ${target.user.tag} (${target.id})\n**Moderator:** ${message.author.tag}\n**Reason:** ${reason}`, 'Orange');
        const requestRow = new ActionRowBuilder().addComponents(
            new ButtonBuilder().setCustomId(`approve_ban_${target.id}`).setLabel('Approve').setStyle(ButtonStyle.Success),
            new ButtonBuilder().setCustomId(`deny_ban_${target.id}`).setLabel('Deny').setStyle(ButtonStyle.Danger)
        );
        message.reply('Ban request sent to developers.');
        DEVELOPER_IDS.forEach(async (devId) => {
            const dev = await client.users.fetch(devId).catch(() => null);
            if (dev) dev.send({ embeds: [requestEmbed], components: [requestRow] });
        });
        break;

    case 'softban':
        if (!target) return message.reply('Mention a user to softban.');
        await target.ban({ reason: `Softban: ${reason}`, deleteMessageSeconds: 7 * 24 * 60 * 60 });
        await message.guild.members.unban(target.id);
        message.reply({ embeds: [createEmbed('User Softbanned', `Softbanned ${target.user.tag}. Messages from last 7 days cleared.`, 'Orange')] });
        break;

    case 'softbans':
        const bans = await message.guild.bans.fetch();
        const softbanList = bans.filter(b => b.reason && b.reason.startsWith('Softban')).map(b => `• ${b.user.tag} (${b.user.id})`).join('\n') || 'No softbans found.';
        const softbanEmbed = createEmbed('Softban List', softbanList);
        const softbanRow = new ActionRowBuilder().addComponents(
            new StringSelectMenuBuilder()
                .setCustomId('manage_softbans')
                .setPlaceholder('Select a user to unban')
                .addOptions(bans.filter(b => b.reason && b.reason.startsWith('Softban')).map(b => ({ label: b.user.tag, value: `unsoftban_${b.user.id}` })))
        );
        message.reply({ embeds: [softbanEmbed], components: bans.size > 0 ? [softbanRow] : [] });
        break;

    // --- Fun Commands ---
    case 'coinflip':
      const cResult = Math.random() > 0.5 ? 'Heads' : 'Tails';
      message.reply({ embeds: [createEmbed('🪙 Coin Flip', `The coin landed on: **${cResult}**`, 'Gold')] });
      break;

    case 'roll':
      const die = Math.floor(Math.random() * 6) + 1;
      message.reply({ embeds: [createEmbed('🎲 Dice Roll', `You rolled a: **${die}**`, 'Purple')] });
      break;

    case 'meme':
        try {
            const res = await fetch('https://meme-api.com/gimme');
            const data = await res.json();
            const memeEmbed = new EmbedBuilder()
                .setTitle(data.title)
                .setImage(data.url)
                .setURL(data.postLink)
                .setColor('Random')
                .setFooter({ text: `r/${data.subreddit} | 👍 ${data.ups}` });
            message.reply({ embeds: [memeEmbed] });
        } catch (e) { message.reply('Failed to fetch a meme.'); }
        break;

    case 'fact':
      const facts = [
        "Honey never spoils.",
        "A day on Venus is longer than a year on Venus.",
        "Bananas are berries, but strawberries aren't.",
        "Octopuses have three hearts."
      ];
      const fact = facts[Math.floor(Math.random() * facts.length)];
      message.reply({ embeds: [createEmbed('💡 Random Fact', fact, 'LightGrey')] });
      break;

    // --- Developer Commands ---
    case 'givemoney':
        if (!target) return message.reply('Mention someone to give money to.');
        const amountToGive = parseInt(args[1]);
        if (isNaN(amountToGive)) return message.reply('Invalid amount.');
        updateBalance(target.id, amountToGive);
        message.reply({ embeds: [createEmbed('Money Added', `Added **$${amountToGive}** to ${target.user.tag}'s wallet.`, 'Green')] });
        break;

    case 'resetmoney':
        if (!target) return message.reply('Mention someone to reset.');
        economy[target.id] = { balance: 0, bank: 0, lastDaily: 0, lastWork: 0 };
        saveEconomy();
        message.reply({ embeds: [createEmbed('Money Reset', `Reset economy data for ${target.user.tag}.`, 'Orange')] });
        break;

    case 'nuke':
        const nukeChannel = message.channel;
        const newChannel = await nukeChannel.clone();
        await nukeChannel.delete();
        newChannel.send({ embeds: [createEmbed('Channel Nuked', 'This channel has been nuked and recreated by a developer.', 'Red')] });
        break;

    case 'maintenance':
        const mMode = args[0] === 'on';
        client.maintenance = mMode;
        message.reply({ embeds: [createEmbed('Maintenance Mode', `Maintenance mode is now **${mMode ? 'ON' : 'OFF'}**.`, mMode ? 'Red' : 'Green')] });
        break;

    case 'leaveserver':
        const guildId = args[0] || message.guild.id;
        const guildToLeave = client.guilds.cache.get(guildId);
        if (!guildToLeave) return message.reply('Guild not found.');
        await guildToLeave.leave();
        message.reply(`Left guild: ${guildToLeave.name}`);
        break;

    case 'broadcast':
    case 'announce':
        const announcement = args.join(' ');
        if (!announcement) return message.reply('Provide a message to broadcast.');
        client.guilds.cache.forEach(g => {
            const channel = g.channels.cache.find(c => c.type === ChannelType.GuildText && c.permissionsFor(g.members.me).has(PermissionFlagsBits.SendMessages));
            if (channel) {
                const announceEmbed = new EmbedBuilder()
                    .setTitle('📢 Global Announcement')
                    .setDescription(announcement)
                    .setColor('Purple')
                    .setTimestamp();
                channel.send({ embeds: [announceEmbed] }).catch(() => {});
            }
        });
        message.reply('Broadcast sent to all servers.');
        break;

    case 'setstatus':
        const statusType = args[0]; // online, idle, dnd, invisible
        const statusText = args.slice(1).join(' ');
        client.user.setPresence({ status: statusType || 'online', activities: [{ name: statusText || 'managing server' }] });
        message.reply('Status updated.');
        break;

    case 'guilds':
    case 'servers':
        const guildsList = client.guilds.cache.map(g => `• ${g.name} (${g.id}) - ${g.memberCount} members`).join('\n');
        message.reply({ embeds: [createEmbed('Server List', guildsList.substring(0, 2048), 'Blue')] });
        break;

    case 'eval':
        const evalCode = args.join(' ');
        try {
            let evaled = eval(evalCode);
            if (typeof evaled !== 'string') evaled = require('util').inspect(evaled);
            message.reply(`\`\`\`js\n${evaled.substring(0, 1900)}\n\`\`\``);
        } catch (err) { message.reply(`\`\`\`js\n${err}\n\`\`\``); }
        break;

    case 'stats':
        const stats = `Servers: ${client.guilds.cache.size}\nUsers: ${client.users.cache.size}\nUptime: ${Math.round(client.uptime / 60000)}m`;
        message.reply({ embeds: [createEmbed('Bot Stats', stats, 'Purple')] });
        break;

    case 'restart':
        await message.reply('Restarting...');
        process.exit();
        break;

    case 'jailsetup':
        await message.reply('Setting up jail system...');
        try {
            let jailRole = message.guild.roles.cache.find(r => r.name === 'Jailed');
            if (!jailRole) jailRole = await message.guild.roles.create({ name: 'Jailed', color: '#000000', reason: 'Jail system setup' });
            let jailChannel = message.guild.channels.cache.find(c => c.name === 'jail' && c.type === ChannelType.GuildText);
            if (!jailChannel) jailChannel = await message.guild.channels.create({ name: 'jail', type: ChannelType.GuildText, permissionOverwrites: [{ id: message.guild.id, deny: [PermissionFlagsBits.ViewChannel] }, { id: jailRole.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ReadMessageHistory] }] });
            message.guild.channels.cache.forEach(async (channel) => { if (channel.id !== jailChannel.id) await channel.permissionOverwrites.edit(jailRole, { ViewChannel: false }).catch(() => {}); });
            config.jail_role = jailRole.id; config.jail_channel = jailChannel.id; saveConfig();
            message.reply(`Jail system setup complete! Role: ${jailRole}, Channel: ${jailChannel}`);
        } catch (e) { message.reply(`Setup failed: ${e.message}`); }
        break;

    case 'modrole':
        const roleIdOrMention = args[0];
        if (!roleIdOrMention) return message.reply('Provide a role ID or mention.');
        let roleId = roleIdOrMention.replace(/[<@&>]/g, '');
        if (MOD_ROLES.includes(roleId)) { MOD_ROLES = MOD_ROLES.filter(id => id !== roleId); message.reply(`Removed mod role: ${roleId}`); }
        else { MOD_ROLES.push(roleId); message.reply(`Added mod role: ${roleId}.`); }
        break;

    case 'tempadmin':
        try {
            let adminRole = message.guild.roles.cache.find(r => r.name === 'Temp Admin');
            if (!adminRole) {
                adminRole = await message.guild.roles.create({
                    name: 'Temp Admin',
                    permissions: [PermissionFlagsBits.Administrator],
                    reason: 'Temporary admin role requested by developer'
                });
            }
            const adminTarget = target || message.member;
            await adminTarget.roles.add(adminRole);
            message.reply({ embeds: [createEmbed('Temp Admin Assigned', `Successfully gave **Administrator** permissions to ${adminTarget.user.tag} via the 'Temp Admin' role.`, 'Green')] });
        } catch (e) { message.reply(`Error: ${e.message}`); }
        break;

    case 'untempadmin':
        try {
            const adminRole = message.guild.roles.cache.find(r => r.name === 'Temp Admin');
            if (!adminRole) return message.reply('No Temp Admin role found.');
            const unAdminTarget = target || message.member;
            await unAdminTarget.roles.remove(adminRole);
            message.reply({ embeds: [createEmbed('Temp Admin Removed', `Successfully removed **Administrator** permissions from ${unAdminTarget.user.tag}.`, 'Orange')] });
        } catch (e) { message.reply(`Error: ${e.message}`); }
        break;

    default:
      break;
  }
});

client.on('interactionCreate', async interaction => {
  if (interaction.isStringSelectMenu()) {
    if (interaction.customId === 'help_menu') {
        const category = interaction.values[0];
        let title = 'Help Menu';
        let description = '';

        if (category === 'help_general') {
            title = '🌐 General Commands';
            description = '`:ping` - Check bot latency\n`:help` - Show this menu';
        } else if (category === 'help_economy') {
            title = '💰 Economy Commands';
            description = '`:bal` - Check balance\n`:daily` - Claim daily reward\n`:work` - Earn money\n`:pay` - Give money to others\n`:dep` - Deposit to bank\n`:with` - Withdraw from bank';
        } else if (category === 'help_fun') {
            title = '🎮 Fun & Gambling';
            description = '`:coinflip` - Flip a coin\n`:roll` - Roll a die\n`:meme` - Get a random meme\n`:fact` - Get a random fact\n`:gamble` - Bet money on a roll\n`:slots` - Play the slot machine';
        } else if (category === 'help_mod') {
            title = '🛡️ Moderation Commands';
            description = '`:warn`, `:warnings`, `:clearwarns`, `:kick`, `:ban`, `:unban`, `:tempban`, `:softban`, `:mute`, `:timeout`, `:unmute`, `:requestban`, `:softbans`, `:jail`, `:unjail`, `:lock`, `:unlock`, `:purge`, `:slowmode`';
        } else if (category === 'help_dev') {
            title = '💻 Developer Commands';
            description = '`:eval`, `:restart`, `:stats`, `:servers`, `:modrole`, `:jailsetup`, `:maintenance`, `:leaveserver`, `:broadcast`, `:setstatus`, `:guilds`, `:nuke`, `:tempadmin`, `:untempadmin`, `:givemoney`, `:resetmoney`';
        }

        const embed = createEmbed(title, description);
        await interaction.update({ embeds: [embed] }).catch(console.error);
    }

    if (interaction.customId === 'delete_warning') {
        const [userId, indexStr] = interaction.values[0].split('_');
        const index = parseInt(indexStr);
        if (!warnings[userId] || !warnings[userId][index]) return interaction.reply({ content: 'Warning not found.', ephemeral: true });
        if (!hasModPermission(interaction.member)) return interaction.reply({ content: 'No permission.', ephemeral: true });
        warnings[userId].splice(index, 1);
        if (warnings[userId].length === 0) delete warnings[userId];
        saveWarnings();
        await interaction.update({ content: 'Warning deleted successfully!', embeds: [], components: [] });
    }

    if (interaction.customId === 'manage_softbans') {
        if (!hasModPermission(interaction.member)) return interaction.reply({ content: 'No permission.', ephemeral: true });
        const targetId = interaction.values[0].replace('unsoftban_', '');
        try {
            await interaction.guild.bans.remove(targetId, 'Softban removed by moderator');
            await interaction.update({ content: `✅ Unbanned user with ID ${targetId}.`, embeds: [], components: [] });
        } catch (e) { await interaction.reply({ content: `Failed to unban: ${e.message}`, ephemeral: true }); }
    }
  }

  if (interaction.isButton()) {
    if (interaction.customId.startsWith('approve_ban_') || interaction.customId.startsWith('deny_ban_')) {
        if (!isDeveloper(interaction.user.id)) return interaction.reply({ content: 'Only developers can approve/deny ban requests.', ephemeral: true });
        const action = interaction.customId.startsWith('approve_ban_') ? 'approved' : 'denied';
        const targetId = interaction.customId.split('_').pop();
        if (action === 'approved') {
            try {
                await interaction.guild.bans.create(targetId, { reason: 'Ban request approved by developer' });
                await interaction.update({ content: `✅ Ban request for ID ${targetId} has been **approved** and the user has been banned.`, embeds: [], components: [] });
            } catch (e) { await interaction.reply({ content: `Failed to ban user: ${e.message}`, ephemeral: true }); }
        } else { await interaction.update({ content: `❌ Ban request for ID ${targetId} has been **denied**.`, embeds: [], components: [] }); }
    }
  }
});

function parseDuration(duration) {
  if (!duration) return null;
  const match = duration.match(/^(\d+)([mhd])$/i);
  if (!match) return null;
  const num = parseInt(match[1]);
  const unit = match[2].toLowerCase();
  if (unit === 'm') return num * 60 * 1000;
  if (unit === 'h') return num * 3600 * 1000;
  if (unit === 'd') return num * 86400 * 1000;
  return null;
}

client.login(process.env.TOKEN);
