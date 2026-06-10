import os
import sys
import xml.etree.ElementTree as ET


def create_item(name, class_name, content=None):
    item = ET.Element("Item", {"class": class_name, "referent": "RBX" + os.urandom(4).hex()})
    properties = ET.SubElement(item, "Properties")
    name_prop = ET.SubElement(properties, "string", {"name": "Name"})
    name_prop.text = name

    if content is not None:
        source_prop = ET.SubElement(properties, "ProtectedString", {"name": "Source"})
        source_prop.text = content

    return item


def add_lua_children(parent, root_path, sub_path, class_resolver):
    dir_path = os.path.join(root_path, sub_path)
    if not os.path.exists(dir_path):
        return

    for file_name in sorted(os.listdir(dir_path)):
        if file_name.endswith(".lua"):
            file_path = os.path.join(dir_path, file_name)
            with open(file_path, "r", encoding="utf-8") as file:
                raw_content = file.read()
                lua_content = "\n".join(line.rstrip() for line in raw_content.splitlines()) + "\n"

            class_name = class_resolver(file_name)
            script_item = create_item(file_name.replace(".lua", ""), class_name, lua_content)
            parent.append(script_item)


def build_rbxmx(root_path=".", output_file="NexusAdmin.rbxmx"):
    roblox_root = ET.Element("roblox", {
        "xmlns:xmime": "http://www.w3.org/2005/05/xmlmime",
        "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:noNamespaceSchemaLocation": "http://www.roblox.com/roblox.xsd",
        "version": "4"
    })

    main_folder = create_item("NexusAdmin", "Folder")
    roblox_root.append(main_folder)

    core_folder = create_item("Core", "Folder")
    main_folder.append(core_folder)

    for sub in ["Server", "Client", "Shared"]:
        sub_folder = create_item(sub, "Folder")
        core_folder.append(sub_folder)

        def resolve_class(file_name, sub_name=sub):
            if sub_name == "Server" and file_name == "Main.lua":
                return "Script"
            if sub_name == "Client":
                return "LocalScript"
            return "ModuleScript"

        add_lua_children(sub_folder, root_path, os.path.join("Core", sub), resolve_class)

    ui_folder = create_item("UI", "Folder")
    main_folder.append(ui_folder)
    add_lua_children(ui_folder, root_path, "UI", lambda _file_name: "ModuleScript")

    tree = ET.ElementTree(roblox_root)
    tree.write(output_file, encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    output = sys.argv[2] if len(sys.argv) > 2 else "NexusAdmin.rbxmx"
    build_rbxmx(root, output)
    print(f"{output} generated successfully from {root}.")
