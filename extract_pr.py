import subprocess
import os

# Define your paths and arguments
pr_number = 135344  # Replace with the correct PR number
base_branch = 'main'  # Default base branch or replace with specific one
source_repo_url = 'https://github.com/llvm/llvm-project.git'  # Replace with the source repo URL

# Path to your bash script (make sure it's correct)
script_path = './check_pr_format.sh'  # If the script is in the same directory as this Python file
# Or use an absolute path like: script_path = '/path/to/check_pr_format.sh'

# Verify the script exists
if not os.path.exists(script_path):
    print(f"Error: The script {script_path} does not exist!")
else:
    # Ensure the script is executable
    os.chmod(script_path, 0o755)

    # Build the bash command
    bash_command = f"bash {script_path} {pr_number} {base_branch} {source_repo_url}"

    # Run the command
    try:
        process = subprocess.Popen(bash_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()

        # Output from the script
        print(f"Output:\n{stdout.decode()}")
        if stderr:
            print(f"Error:\n{stderr.decode()}")
    except Exception as e:
        print(f"Error executing the script: {e}")
