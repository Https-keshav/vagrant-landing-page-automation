# Vagrant Landing Page Hosting Automation

Automated setup for hosting landing pages on a Vagrant VirtualBox VM with Apache (httpd), featuring a flexible `Deploy.sh` script that supports multiple deployment methods.

**Perfect for:** DevOps learning, infrastructure automation, portfolio projects, quick landing page hosting.

---

## 🎯 Features

- ✅ **One-command VM setup** with Vagrant
- ✅ **Automated Apache web server** installation & configuration
- ✅ **Flexible deployment** - 3 ways to host your landing page
- ✅ **SELinux & permission handling** for production-ready setup
- ✅ **Cross-platform** - Works on macOS, Linux, Windows (with Vagrant + VirtualBox)

---

## 📋 Prerequisites

Install on your **host machine** (your laptop/desktop):

1. **VirtualBox** - [Download](https://www.virtualbox.org/wiki/Downloads)
2. **Vagrant** - [Download](https://www.vagrantup.com/downloads)
3. **Git** (optional, for cloning this repo)

Verify installation:
```bash
vboxmanage --version
vagrant --version
```

---

## 🚀 Quick Start

### 1. Clone or Download This Repository

```bash
git clone https://github.com/Https-keshav/vagrant-landing-page-automation.git
cd vagrant-landing-page-automation
```

Or download the ZIP and extract it.

### 2. Start the Vagrant VM

```bash
vagrant up
```

This will:
- Download the CentOS/RHEL box (if not cached)
- Create and start the VM
- Run provisioning scripts
- Install dependencies (Apache, wget, unzip, vim)
- Start the httpd service

**First-time setup takes 2-5 minutes.**

### 3. Deploy Your Landing Page (Choose ONE method below)

---

## 📤 Deployment Options

### **Option 1: Local Zip File** (Recommended for Quick Testing)

Best for: Testing locally, small projects, offline work.

#### Step A: Add your landing page zip to the project folder

```bash
# On your HOST machine
# Copy your landing page (zipped) to the project root
cp ~/Downloads/2170_aperture.zip ./landing-page.zip

# Or if it's a folder instead:
zip -r landing-page.zip ~/path/to/your/landing-page-folder
```

#### Step B: Create a shared folder in Vagrant

Edit your `Vagrantfile` and ensure this line exists (usually already there):
```ruby
config.vm.synced_folder ".", "/vagrant"
```

Reload Vagrant:
```bash
vagrant reload
```

#### Step C: SSH into the VM and deploy

```bash
# SSH into the VM
vagrant ssh

# Deploy from the shared /vagrant folder
./Deploy.sh /vagrant/landing-page.zip
```

#### Expected Output:
```
==> Detected local zip file. Unzipping...
==> Clearing old web root content...
==> Copying site files to /var/www/html...
==> Restarting httpd...
==> Deployment complete!
 Open this in your browser: http://192.168.56.101
```

**Access your site:** Open `http://192.168.56.101` in your browser (IP varies, check output)

---

### **Option 2: Zip URL** (Best for Automation & CI/CD)

Best for: Automated deployments, cloud storage (GitHub releases, S3), no file transfers.

#### Step A: Host your landing page zip online

Options:
- Upload to **GitHub Releases** (free)
- Use **AWS S3**, **Google Cloud Storage**, or **Azure Blob**
- Host on any web server with a public URL

#### Step B: Get the raw download URL

Example GitHub Release URL:
```
https://github.com/your-username/your-repo/releases/download/v1.0/landing-page.zip
```

#### Step C: Deploy from the VM

```bash
# SSH into the VM
vagrant ssh

# Run the script with the URL
./Deploy.sh https://github.com/your-username/your-repo/releases/download/v1.0/landing-page.zip
```

**Advantages:**
- No local file transfers
- Works for remote deployments
- Easy CI/CD integration (GitHub Actions, Jenkins, etc.)
- Version control for releases

---

### **Option 3: Local Folder** (Best for Development)

Best for: Active development, live editing, iterating on design.

#### Step A: Create your landing page folder structure

```bash
mkdir -p ~/my-landing-page
cd ~/my-landing-page
```

Add your files:
```
my-landing-page/
├── index.html
├── style.css
├── assets/
│   └── logo.png
└── js/
    └── script.js
```

#### Step B: Share the folder with Vagrant

Edit `Vagrantfile` to add:
```ruby
config.vm.synced_folder "/Users/keshavtoshniwal/my-landing-page", "/home/vagrant/my-site"
```

Reload:
```bash
vagrant reload
```

#### Step C: Deploy the folder

```bash
# SSH into the VM
vagrant ssh

# Deploy directly from the shared folder
./Deploy.sh /home/vagrant/my-site
```

**For live development:**
Edit files on your **host machine**. Changes reflect instantly on the served website because the folder is shared.

```bash
# Your editor on macOS/Windows/Linux
vim ~/my-landing-page/index.html

# Immediately visible at http://192.168.56.101 in your browser
```

---

## 🔧 Common Tasks

### Check VM Status
```bash
vagrant status
```

### Connect to the VM
```bash
vagrant ssh
```

### Stop the VM (save resources)
```bash
vagrant halt
```

### Restart the VM
```bash
vagrant reload
```

### Destroy the VM (clean up)
```bash
vagrant destroy
```

### View Apache logs
```bash
vagrant ssh
sudo tail -f /var/log/httpd/access_log
```

### Verify Apache is running
```bash
vagrant ssh
sudo systemctl status httpd
```

---

## 📁 Project Structure

```
vagrant-landing-page-automation/
├── Vagrantfile              # VM configuration (OS, network, provisioning)
├── Deploy.sh                # Deployment script (main automation)
├── README.md                # This file
├── .gitignore               # Git ignore rules
├── LICENSE                  # MIT License

```

---

## ⚙️ Customization

### Change VM IP Address

Edit `Vagrantfile`:
```ruby
config.vm.network "private_network", ip: "192.168.56.110"
```

Then:
```bash
vagrant reload
```

### Change VM RAM/CPU

Edit `Vagrantfile`:
```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = 2048  # MB
  vb.cpus = 2
end
```

### Use Different Base OS

Edit `Vagrantfile` (currently uses CentOS/RHEL):
```ruby
config.vm.box = "bento/ubuntu-22.04"  # For Ubuntu
```

---

## 🐛 Troubleshooting

### "Could not recognize source: /Users/..."
**Problem:** Trying to use a macOS host path from inside the VM.

**Solution:** Use one of the 3 options above (zip file via `/vagrant`, URL, or shared folder).

```bash
# ❌ Don't do this
./Deploy.sh /Users/keshavtoshniwal/Downloads/site.zip

# ✅ Do this instead
./Deploy.sh /vagrant/site.zip
```

### "Connection refused" when accessing site
**Problem:** VM not running or httpd not started.

**Solution:**
```bash
vagrant status          # Check if VM is running
vagrant up              # Start it
vagrant ssh             # Connect
sudo systemctl status httpd  # Check Apache
```

### "Permission denied" when running Deploy.sh
**Problem:** Script is not executable.

**Solution:**
```bash
# Inside VM or on host
chmod +x Deploy.sh
```

### "unzip: command not found"
**Problem:** Dependencies not installed.

**Solution:**
```bash
vagrant ssh
sudo yum install -y unzip wget
```

---

## 📚 Learning Resources

- **Vagrant Docs:** [vagrantup.com](https://www.vagrantup.com/docs)
- **VirtualBox Docs:** [virtualbox.org](https://www.virtualbox.org/wiki/Documentation)
- **Apache httpd:** [httpd.apache.org](https://httpd.apache.org/docs/)
- **Shell Scripting:** [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)

---

## 🤝 Contributing

Feel free to fork, improve, and submit PRs!

Potential improvements:
- [ ] Add Nginx configuration
- [ ] Support for Let's Encrypt SSL
- [ ] Docker alternative
- [ ] GitHub Actions workflow example
- [ ] Python HTTP server option

---

## 📜 License

MIT License - See `LICENSE` file for details.

---

## 👨‍💻 Author

**Keshav Toshniwal**  
- GitHub: [@Https-keshav](https://github.com/Https-keshav)
- Learning DevOps & Cloud Infrastructure

---

## 💡 Use Cases

✅ **Portfolio Project** - Host a landing page to showcase your work  
✅ **DevOps Learning** - Practice infrastructure automation  
✅ **Quick Prototyping** - Spin up a web server in seconds  
✅ **CI/CD Practice** - Integrate with GitHub Actions  
✅ **Interview Prep** - Show practical infrastructure skills  

---

## 🚀 Next Steps

1. **Try all 3 deployment options** to understand the differences
2. **Customize the VM** (add Nginx, databases, etc.)
3. **Automate further** with GitHub Actions or Jenkins
4. **Document your process** and add to this repo
5. **Share on LinkedIn** to build your portfolio 💼

---

**Happy hosting! 🎉**
