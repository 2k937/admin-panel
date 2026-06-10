import os
import json

def generate_summary():
    project_dir = "nexus_admin"
    summary = {
        "Project": "Nexus Admin",
        "Files": []
    }
    for root, dirs, files in os.walk(project_dir):
        for file in files:
            summary["Files"].append(os.path.join(root, file))
    
    with open("nexus_admin_summary.json", "w") as f:
        json.dump(summary, f, indent=4)

if __name__ == "__main__":
    generate_summary()
    print("Nexus Admin assembly summary generated.")
