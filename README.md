# Duplicate Junk Remover Command-Line Utility

##### This is a bash script command line utility that handles duplicate files with the same content but different filenames.

## Usage
---

To list all the unique files in a directory:

	bash bash_script.sh -lt /home/example/directory

To remove all the duplicate files in the directory and keep and single copy of every file:
	
	bash bash_script.sh /home/example/directory

**Note :**  
- The duplicate files will be permanently deteled using `rm` command and will not be recoverable
- Include `sudo` keyword when handling previlaged files

To create a new copy of the directory with only the unique files in it:

	bash bash_script.sh -wtd /home/example/directory

**Note :** The new directory with all the unique files in it will be 
stored in the dirctory in which the directory entered as the command line
 argument was present 
