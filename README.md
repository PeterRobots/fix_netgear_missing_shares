# fix_netgear_missing_shares
How to fix missing shares on Netgear Readynas 6.0
This guide is for missing shares due to corruption of the share config files.

# What you need: 
- The name of the data volume containing all the shares (check the webgui and shares, it's on the left in big text)
![share_name](https://github.com/PeterRobots/fix_netgear_missing_shares/blob/main/netgear_share.png?raw=true)
- SSH access to your NAS 
	- https://kb.netgear.com/30068/ReadyNAS-OS-6-SSH-access-support-and-configuration-guides
- A new share with permissions, config and protocols you want to copy from
- The name of your missing share folder

# Verify the issue:
First step is to make sure your issue is compatible with this fix.
1) SSH into your NAS
2) Navigate to your Data volume
	- `cd ~/Data`
3) Verify your shares exist and have size.
	- `ls -l .`
	- You should see your shares listed with non-zero size.
	- List or navigate into your shares to verify they contain everything  you expect
4) List the contents of the share configuration folder for your missing share
	- `ls -l ._share/YOURMISSINGSHARE`
	- If the `.conf` files are mostly size 0, then they are corrupt and likely can be fixed with this method
	 ![Broken share](https://github.com/PeterRobots/fix_netgear_missing_shares/blob/main/netgear_broken_share_configs.png?raw=true)
	 - If any protocols you intend to use are size 0, then this also applies

If your shares still exist and the `._share/.conf` are corrupted it's good news, this method should recover access to these shares via sharing protocols and webgui access.
If you have space on the NAS or elsewhere it is worth backing up the shares before continuing.

# How to fix:
You can fix the share config files manually or use the script provided.
Please have a look at the script and make sure you understand what it does.

**To fix manually:**
- Backup the broken configuration
- Copy the `.conf` files from a working share (make a new one)
	- `._share/WORKINGSHARE/*.conf` to `._share/BROKENSHARE/`
- Reboot the NAS

**Script**
The script automates the above and creates a backup of the share configs at `._share/.BROKENSHARECONFIG.old`
If run multiple times it will increment the backup.
Run the script with:
```bash
cd DATAVOLUMEPATH
wget https://github.com/PeterRobots/fix_netgear_missing_shares/blob/main/fix_nas_shares.sh
sudo chmod +x fix_nas_shares.sh
sudo ./fix_nas_shares.sh -i /path/to/working/share -o /path/to/corrupt/share
```
An example of script output:
![Output example](https://github.com/PeterRobots/fix_netgear_missing_shares/blob/main/script_example_output.png?raw=true)
- I have the script installed in my `Documents/scripts`
- My volume is `Data`
- My broken share folder is `shared_folder`
- My working share folder is `Documents`
- If you SSH in as `root` as I have, exclude the `sudo` commands above
	- `root` is not necessary and you can ssh in as an user with admin privileges
