import os

def main():
    md_file = "StudentOnlineLeaveApplicationSystem.md"
    if not os.path.exists(md_file):
        print(f"Error: {md_file} not found in current directory.")
        return

    print("Reading markdown file and extracting project structure...")
    with open(md_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    current_path = None
    inside_code_block = False
    code_lines = []
    files_created = 0

    for line in lines:
        # Check if this line specifies a file path
        if "**Path:**" in line:
            # Extract path between backticks
            parts = line.split("`")
            if len(parts) >= 2:
                current_path = parts[1].strip()
                # Normalize paths for Windows/Linux
                current_path = os.path.normpath(current_path)
        
        elif line.startswith("```") and current_path:
            if not inside_code_block:
                inside_code_block = True
                code_lines = []
            else:
                # Code block ends, save the file
                inside_code_block = False
                
                # Make sure the parent directories exist
                dir_name = os.path.dirname(current_path)
                if dir_name:
                    os.makedirs(dir_name, exist_ok=True)
                
                # Write file content
                with open(current_path, "w", encoding="utf-8") as out_f:
                    out_f.writelines(code_lines)
                
                print(f" -> Created file: {current_path}")
                files_created += 1
                current_path = None
                
        elif inside_code_block:
            code_lines.append(line)

    print(f"\nSuccess! Extracted {files_created} files in their respective folders.")

if __name__ == "__main__":
    main()
