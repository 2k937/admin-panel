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
  PermissionFlagsBits
} = require('discord.js');
const fs = require('fs');
const dotenv = require('dotenv');

dotenv.config();

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

// Load warnings
let warnings = {};
if (fs.existsSync(WARNINGS_FILE)) {
  warnings = JSON.parse(fs.readFileSync(WARNINGS_FILE, 'utf8'));
} else {
  fs.writeFileSync(WARNINGS_FILE, JSON.stringify({}, null, 2));
}

// Save warnings
function saveWarnings() {
  fs.writeFileSync(WARNINGS_FILE, JSON.stringify(warnings, null, 2));
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

client.once('ready', () => {
  console.log(`Bot is ready! Logged in as ${client.user.tag}`);

  // Rotating statuses
  const statuses = [
    "managing members",
    "staff actions",
    "ban appeals",
    "server safety",
    "moderation logs"
  ];

  let i = 0;
  setInterval(() => {
    const status = statuses[i];
    client.user.setActivity(status, { type: 3 }); // Watching
    i = (i + 1) % statuses.length;
  }, 60000);
});

client.on('messageCreate', async message => {
  if (message.author.bot || !message.guild || !message.content.startsWith(PREFIX)) return;

  const args = message.content.slice(PREFIX.length).trim().split(/ +/);
  const command = args.shift().toLowerCase();
  const member = message.member;

  // General & Fun commands are accessible to all
  const generalCommands = ['ping', 'help'];
  const funCommands = ['8ball', 'hug', 'slap', 'joke', 'coinflip', 'roll', 'meme', 'fact'];
  
  const isModCmd = ['warn', 'warnings', 'clearwarns', 'kick', 'ban', 'tempban', 'softban', 'mute', 'timeout', 'unmute', 'unban', 'requestban'].includes(command);
  const isDevCmd = ['modrole', 'eval', 'restart', 'stats', 'servers'].includes(command);

  if (isModCmd && !hasModPermission(member)) {
    return message.reply('You do not have permission to use moderation commands.');
  }

  if (isDevCmd && !isDeveloper(message.author.id)) {
    return message.reply('This command is restricted to developers only.');
  }

  // Target resolution (mention or ID)
  let target = message.mentions.members.first();
  let idIndex = 0;
  if (!target && args[0]) {
    const possibleId = args[0].replace(/[<@!>]/g, '').trim();
    if (possibleId.length >= 17) {
        target = await message.guild.members.fetch(possibleId).catch(() => null);
        idIndex = 1;
    }
  }

  const reason = args.slice(idIndex).join(' ') || 'No reason provided';

  // Hierarchy check for mod commands
  const hierarchyCommands = ['warn', 'kick', 'ban', 'tempban', 'softban', 'mute', 'timeout', 'unmute'];
  if (hierarchyCommands.includes(command) && target) {
    if (!canModerate(member, target)) {
      return message.reply('You cannot moderate this user (self or hierarchy).');
    }
  }

  switch (command) {
    // --- General Commands ---
    case 'ping':
      const pingEmbed = new EmbedBuilder()
        .setColor('Green')
        .setDescription(`🏓 Latency: **${Math.round(client.ws.ping)}ms**`);
      message.reply({ embeds: [pingEmbed] });
      break;

    case 'help':
      const helpEmbed = new EmbedBuilder()
        .setTitle('Bot Help Menu')
        .setDescription('Select a category from the dropdown below to view commands.')
        .setColor('Blue');

      const helpOptions = [
        { label: 'General', description: 'Basic commands for everyone', value: 'help_general', emoji: '🌐' },
        { label: 'Fun', description: 'Entertainment commands', value: 'help_fun', emoji: '🎮' },
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

    // --- Moderation Commands ---
    case 'requestban':
        if (!target && !args[0]) return message.reply('Please mention a user or provide a user ID.');
        const targetId = target ? target.id : args[0].replace(/[<@!>]/g, '').trim();
        const targetTag = target ? target.user.tag : `ID: ${targetId}`;
        
        const devPings = DEVELOPER_IDS.map(id => `<@${id}>`).join(' ');
        
        const requestEmbed = new EmbedBuilder()
            .setTitle('Ban Request')
            .setDescription(`A moderator has requested a ban on a user.`)
            .addFields(
                { name: 'Moderator', value: `${message.author} (${message.author.tag})` },
                { name: 'Target', value: `${targetTag} (${targetId})` },
                { name: 'Reason', value: reason }
            )
            .setColor('Orange')
            .setTimestamp();

        const requestButtons = new ActionRowBuilder().addComponents(
            new ButtonBuilder()
                .setCustomId(`approve_ban_${targetId}`)
                .setLabel('Approve')
                .setStyle(ButtonStyle.Danger),
            new ButtonBuilder()
                .setCustomId(`deny_ban_${targetId}`)
                .setLabel('Deny')
                .setStyle(ButtonStyle.Secondary)
        );

        message.channel.send({ 
            content: `${devPings}\nModerator ${message.author.tag} requested a ban on user ${targetTag}`, 
            embeds: [requestEmbed], 
            components: [requestButtons] 
        });
        message.reply('Ban request sent to developers.');
        break;

    case 'warn':
      if (!target) return message.reply('Please mention a user to warn.');
      if (!warnings[target.id]) warnings[target.id] = [];
      warnings[target.id].push({ reason, moderator: message.author.tag, timestamp: new Date().toISOString() });
      saveWarnings();

      const warnEmbed = new EmbedBuilder()
        .setTitle('Warning Issued')
        .setDescription(`You have been warned in ${message.guild.name}`)
        .addFields(
          { name: 'Reason', value: reason },
          { name: 'Moderator', value: message.author.tag }
        )
        .setColor('Yellow')
        .setTimestamp();

      await sendDM(target.user, { embeds: [warnEmbed] });
      message.reply(`Warned ${target.user.tag}.`);
      break;

    case 'warnings':
      if (!target) return message.reply('Please mention a user.');
      const userWarnings = warnings[target.id] || [];
      const warnListEmbed = new EmbedBuilder()
        .setTitle(`Warnings for ${target.user.tag}`)
        .setColor('Blue')
        .setTimestamp();

      if (userWarnings.length === 0) {
        warnListEmbed.setDescription('No warnings.');
        return message.reply({ embeds: [warnListEmbed] });
      }

      const options = userWarnings.map((w, i) => ({
        label: `Warning ${i+1}`,
        description: `${w.reason.substring(0, 80)}`,
        value: `${target.id}_${i}`
      }));

      const row = new ActionRowBuilder().addComponents(
        new StringSelectMenuBuilder()
          .setCustomId('delete_warning')
          .setPlaceholder('Select warning to delete')
          .addOptions(options)
      );

      await message.reply({ 
        embeds: [warnListEmbed], 
        components: [row] 
      });
      break;

    case 'clearwarns':
      if (!target) return message.reply('Please mention a user.');
      delete warnings[target.id];
      saveWarnings();
      message.reply(`Cleared warnings for ${target.user.tag}.`);
      break;

    case 'kick':
      if (!target) return message.reply('Please mention a user to kick.');
      if (!target.kickable) return message.reply('Cannot kick this user.');
      await target.kick(reason);
      const kickEmbed = new EmbedBuilder()
        .setTitle('Kicked')
        .setDescription(`You have been kicked from ${message.guild.name}`)
        .addFields({ name: 'Reason', value: reason })
        .setColor('Red')
        .setTimestamp();
      await sendDM(target.user, { embeds: [kickEmbed] });
      message.reply(`Kicked ${target.user.tag}.`);
      break;

    case 'ban':
      if (!target) return message.reply('Please mention a user to ban.');
      await message.guild.bans.create(target.id, { reason, deleteMessageSeconds: 86400 });
      const banEmbed = new EmbedBuilder()
        .setTitle('Banned')
        .setDescription(`You have been banned from ${message.guild.name}`)
        .addFields({ name: 'Reason', value: reason })
        .setColor('DarkRed')
        .setTimestamp();
      await sendDM(target.user, { embeds: [banEmbed] });
      message.reply(`Banned ${target.user.tag}.`);
      break;

    case 'unban':
      const unbanId = args[0];
      if (!unbanId) return message.reply('Provide a user ID to unban.');
      try {
        await message.guild.bans.remove(unbanId, reason);
        message.reply(`Unbanned user with ID ${unbanId}.`);
      } catch (e) {
        message.reply('Failed to unban. Make sure the ID is correct and user is banned.');
      }
      break;

    case 'tempban':
      if (!target) return message.reply('Please mention a user to temp ban.');
      const durationArg = args[1];
      if (!durationArg) return message.reply('Provide duration like 1h, 2d.');
      const timeMs = parseDuration(durationArg);
      if (!timeMs) return message.reply('Invalid duration.');
      
      await message.guild.bans.create(target.id, { reason, deleteMessageSeconds: 86400 });
      const tempBanEmbed = new EmbedBuilder()
        .setTitle('Temporarily Banned')
        .setDescription(`You have been temporarily banned from ${message.guild.name} for ${durationArg}`)
        .addFields({ name: 'Reason', value: reason })
        .setColor('DarkRed')
        .setTimestamp();
      await sendDM(target.user, { embeds: [tempBanEmbed] });
      
      setTimeout(async () => {
        await message.guild.bans.remove(target.id, 'Temp ban expired').catch(() => {});
      }, timeMs);
      
      message.reply(`Temp banned ${target.user.tag} for ${durationArg}.`);
      break;

    case 'softban':
      if (!target) return message.reply('Please mention a user to softban.');
      await message.guild.bans.create(target.id, { reason, deleteMessageSeconds: 604800 });
      await message.guild.bans.remove(target.id, 'Softban');
      const softBanEmbed = new EmbedBuilder()
        .setTitle('Softbanned')
        .setDescription(`You have been softbanned from ${message.guild.name}`)
        .addFields({ name: 'Reason', value: reason })
        .setColor('Orange')
        .setTimestamp();
      await sendDM(target.user, { embeds: [softBanEmbed] });
      message.reply(`Softbanned ${target.user.tag}.`);
      break;

    case 'mute':
    case 'timeout':
      if (!target) return message.reply('Please mention a user to mute.');
      const muteDurationArg = args[1] || '1h';
      const muteTimeMs = parseDuration(muteDurationArg);
      if (!muteTimeMs) return message.reply('Invalid duration.');
      
      await target.timeout(muteTimeMs, reason);
      const muteEmbed = new EmbedBuilder()
        .setTitle('Muted')
        .setDescription(`You have been muted in ${message.guild.name} for ${muteDurationArg}`)
        .addFields({ name: 'Reason', value: reason })
        .setColor('Yellow')
        .setTimestamp();
      await sendDM(target.user, { embeds: [muteEmbed] });
      message.reply(`Muted ${target.user.tag} for ${muteDurationArg}.`);
      break;

    case 'unmute':
      if (!target) return message.reply('Please mention a user to unmute.');
      await target.timeout(null, reason);
      const unmuteEmbed = new EmbedBuilder()
        .setTitle('Unmuted')
        .setDescription(`You have been unmuted in ${message.guild.name}`)
        .setColor('Green')
        .setTimestamp();
      await sendDM(target.user, { embeds: [unmuteEmbed] });
      message.reply(`Unmuted ${target.user.tag}.`);
      break;

    // --- Fun Commands ---
    case '8ball':
      const answers = ["Yes", "No", "Maybe", "Ask again later", "Definitely", "Outlook not so good"];
      message.reply(`🎱 ${answers[Math.floor(Math.random() * answers.length)]}`);
      break;

    case 'hug':
      if (target) message.reply(`🤗 ${message.author} hugged ${target}!`);
      else message.reply('Hug someone! :hug @user');
      break;

    case 'slap':
      if (target) message.reply(`👋 ${message.author} slapped ${target}!`);
      else message.reply('Slap someone! :slap @user');
      break;

    case 'joke':
        const jokes = [
            "Why don't scientists trust atoms? Because they make up everything!",
            "I told my wife she was drawing her eyebrows too high. She looked surprised.",
            "Parallel lines have so much in common. It’s a shame they’ll never meet.",
            "What do you call a fake noodle? An impasta!",
            "Why did the scarecrow win an award? Because he was outstanding in his field!"
        ];
        message.reply(`😂 ${jokes[Math.floor(Math.random() * jokes.length)]}`);
        break;

    case 'coinflip':
        const result = Math.random() < 0.5 ? 'Heads' : 'Tails';
        message.reply(`🪙 The coin landed on: **${result}**!`);
        break;

    case 'roll':
        const die = Math.floor(Math.random() * 6) + 1;
        message.reply(`🎲 You rolled a **${die}**!`);
        break;

    case 'meme':
        message.reply('🖼️ Here is a "meme": [Insert funny image here]');
        break;

    case 'fact':
        const facts = [
            "Honey never spoils.",
            "A day on Venus is longer than a year on Venus.",
            "Bananas are berries, but strawberries aren't.",
            "Octopuses have three hearts.",
            "Wombat poop is cube-shaped."
        ];
        message.reply(`💡 Did you know? ${facts[Math.floor(Math.random() * facts.length)]}`);
        break;

    // --- Developer Commands ---
    case 'modrole':
      const roleIdOrMention = args[0];
      if (!roleIdOrMention) return message.reply('Provide a role ID or mention.');
      
      let roleId = roleIdOrMention;
      if (message.mentions.roles.first()) roleId = message.mentions.roles.first().id;
      
      if (MOD_ROLES.includes(roleId)) {
        MOD_ROLES = MOD_ROLES.filter(id => id !== roleId);
        message.reply(`Removed mod role: ${roleId}`);
      } else {
        MOD_ROLES.push(roleId);
        message.reply(`Added mod role: ${roleId}.`);
      }
      break;

    case 'eval':
        const code = args.join(' ');
        if (!code) return message.reply('Provide code to evaluate.');
        try {
            let evaled = eval(code);
            if (typeof evaled !== 'string') evaled = require('util').inspect(evaled);
            message.reply(`\`\`\`js\n${evaled.substring(0, 1900)}\n\`\`\``);
        } catch (err) {
            message.reply(`\`\`\`js\n${err}\n\`\`\``);
        }
        break;

    case 'restart':
        await message.reply('Restarting bot...');
        process.exit();
        break;

    case 'stats':
        const statsEmbed = new EmbedBuilder()
            .setTitle('Bot Statistics')
            .addFields(
                { name: 'Servers', value: `${client.guilds.cache.size}`, inline: true },
                { name: 'Users', value: `${client.users.cache.size}`, inline: true },
                { name: 'Uptime', value: `${Math.round(client.uptime / 60000)} minutes`, inline: true }
            )
            .setColor('Purple');
        message.reply({ embeds: [statsEmbed] });
        break;

    case 'servers':
        const serverList = client.guilds.cache.map(g => `${g.name} (${g.id})`).join('\n');
        message.reply(`Connected to:\n${serverList.substring(0, 1900)}`);
        break;

    default:
      break;
  }
});

// Interaction handlers
client.on('interactionCreate', async interaction => {
  // Select Menu Handlers
  if (interaction.isStringSelectMenu()) {
    if (interaction.customId === 'delete_warning') {
        const [userId, indexStr] = interaction.values[0].split('_');
        const index = parseInt(indexStr);
      
        if (!warnings[userId] || !warnings[userId][index]) {
          return interaction.reply({ content: 'Warning not found.', ephemeral: true });
        }
      
        if (!hasModPermission(interaction.member)) {
          return interaction.reply({ content: 'No permission.', ephemeral: true });
        }
      
        warnings[userId].splice(index, 1);
        if (warnings[userId].length === 0) delete warnings[userId];
        saveWarnings();
      
        await interaction.update({ content: 'Warning deleted successfully!', embeds: [], components: [] });
    }

    if (interaction.customId === 'help_menu') {
        const category = interaction.values[0];
        const helpEmbed = new EmbedBuilder().setColor('Blue');

        switch (category) {
            case 'help_general':
                helpEmbed.setTitle('🌐 General Commands')
                    .setDescription('`:ping`, `:help`');
                break;
            case 'help_fun':
                helpEmbed.setTitle('🎮 Fun Commands')
                    .setDescription('`:8ball`, `:hug`, `:slap`, `:joke`, `:coinflip`, `:roll`, `:meme`, `:fact`');
                break;
            case 'help_mod':
                helpEmbed.setTitle('🛡️ Moderation Commands')
                    .setDescription('`:warn`, `:warnings`, `:clearwarns`, `:kick`, `:ban`, `:unban`, `:tempban`, `:softban`, `:mute`, `:unmute`, `:requestban`');
                break;
            case 'help_dev':
                if (!isDeveloper(interaction.user.id)) return interaction.reply({ content: 'Restricted.', ephemeral: true });
                helpEmbed.setTitle('💻 Developer Commands')
                    .setDescription('`:eval`, `:restart`, `:stats`, `:servers`, `:modrole`');
                break;
        }
        await interaction.update({ embeds: [helpEmbed] });
    }
  }

  // Button Handlers
  if (interaction.isButton()) {
    if (interaction.customId.startsWith('approve_ban_') || interaction.customId.startsWith('deny_ban_')) {
        if (!isDeveloper(interaction.user.id)) {
            return interaction.reply({ content: 'Only developers can approve/deny ban requests.', ephemeral: true });
        }

        const action = interaction.customId.startsWith('approve_ban_') ? 'approved' : 'denied';
        const targetId = interaction.customId.split('_').pop();

        if (action === 'approved') {
            try {
                await interaction.guild.bans.create(targetId, { reason: 'Ban request approved by developer' });
                await interaction.update({ content: `✅ Ban request for ID ${targetId} has been **approved** and the user has been banned.`, embeds: [], components: [] });
            } catch (e) {
                await interaction.reply({ content: `Failed to ban user: ${e.message}`, ephemeral: true });
            }
        } else {
            await interaction.update({ content: `❌ Ban request for ID ${targetId} has been **denied**.`, embeds: [], components: [] });
        }
    }
  }
});

function parseDuration(duration) {
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
