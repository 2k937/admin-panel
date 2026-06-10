import os
import xml.etree.ElementTree as ET

def create_item(name, class_name, content=None):
    item = ET.Element("Item", {"class": class_name, "referent": "RBX" + os.urandom(4).hex()})
    properties = ET.SubElement(item, "Properties")
    name_prop = ET.SubElement(properties, "string", {"name": "Name"})
    name_prop.text = name
    
    if content:
        source_prop = ET.SubElement(properties, "ProtectedString", {"name": "Source"})
        source_prop.text = content
    
    return item

def build_rbxmx(root_path):
    roblox_root = ET.Element("roblox", {
        "xmlns:xmime": "http://www.w3.org/2005/05/xmlmime",
        "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:noNamespaceSchemaLocation": "http://www.roblox.com/roblox.xsd",
        "version": "4"
    })
    
    main_folder = create_item("NexusAdmin", "Folder")
    roblox_root.append(main_folder)
    
    # Core Folder
    core_folder = create_item("Core", "Folder")
    main_folder.append(core_folder)
    
    # Server, Client, Shared subfolders
    for sub in ["Server", "Client", "Shared"]:
        sub_folder = create_item(sub, "Folder")
        core_folder.append(sub_folder)
        
        dir_path = os.path.join(root_path, "Core", sub)
        if os.path.exists(dir_path):
            for file in os.listdir(dir_path):
                if file.endswith(".lua"):
                    with open(os.path.join(dir_path, file), "r") as f:
                        lua_content = f.read()
                    
                    class_name = "Script" if sub == "Server" and file == "Main.lua" else "ModuleScript"
                    if sub == "Client": class_name = "LocalScript"
                    
                    script_item = create_item(file.replace(".lua", ""), class_name, lua_content)
                    sub_folder.append(script_item)
    
    # UI Folder
    ui_folder = create_item("UI", "Folder")
    main_folder.append(ui_folder)
    ui_path = os.path.join(root_path, "UI")
    if os.path.exists(ui_path):
        for file in os.listdir(ui_path):
            if file.endswith(".lua"):
                with open(os.path.join(ui_path, file), "r") as f:
                    lua_content = f.read()
                ui_item = create_item(file.replace(".lua", ""), "ModuleScript", lua_content)
                ui_folder.append(ui_item)

    tree = ET.ElementTree(roblox_root)
    tree.write("NexusAdmin.rbxmx", encoding="utf-8", xml_declaration=True)

if __name__ == "__main__":
    build_rbxmx("nexus_admin")
    print("NexusAdmin.rbxmx generated successfully.")
