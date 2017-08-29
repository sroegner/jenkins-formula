{%- from "jenkins/map.jinja" import jenkins with context %}
import jenkins.model.*
import hudson.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
import org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl

def instance       = Jenkins.getInstance()
def admin_username = "{{ jenkins.get('admin_username')}}"
def admin_password = "{{ jenkins.get('admin_password')}}"
def hudsonRealm    = new hudson.security.HudsonPrivateSecurityRealm(false)
def users          = hudsonRealm.getAllUsers()
users_s            = users.collect { it.toString() }

// create the admin user if it isn't found
if (admin_username in users_s)
{
  println "admin user " + admin_username + " already exists" 
} else {
  println "Creating admin user " + admin_username
  hudsonRealm.createAccount(admin_username, admin_password)
  instance.setSecurityRealm(hudsonRealm)
  instance.save()
}

adminUser = User.get(admin_username)
// add the jenkins user's ssh pubkey to the admin config for cli auth
// TODO: might want to make the whole key business configurable via pillars at some point
if (new File('/var/lib/jenkins/.ssh/id_rsa.pub').exists())
{
  String pubkey = new File('/var/lib/jenkins/.ssh/id_rsa.pub').text
  println("Attaching Jenkins user pubkey to the " + admin_username + " account" )
  adminUser.addProperty(new UserPropertyImpl(pubkey))
}

