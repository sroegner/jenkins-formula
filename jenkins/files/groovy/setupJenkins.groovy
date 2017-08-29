{%- from "jenkins/map.jinja" import jenkins with context %}
import jenkins.model.*
import hudson.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
import org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl

def instance       = Jenkins.getInstance()
def admin_username = "{{ jenkins.get('admin_usernamename')}}"
def admin_password = "{{ jenkins.get('admin_password')}}"
def hudsonRealm    = new hudson.security.HudsonPrivateSecurityRealm(false)
def strategy

adminUser = User.get(admin_username)

if (Jenkins.instance.getPluginManager().getPlugin("matrix-auth"))
{
  println("initJenkins.groovy: Using matrix-auth plugin to create admin user " + admin_username)
  strategy = new hudson.security.GlobalMatrixAuthorizationStrategy()
  strategy.add(Jenkins.ADMINISTER, admin_username)
} else {
  println("initJenkins.groovy: matrix-auth is not installed - using global auth to create admin user " + admin_username)
  strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
}
instance.setAuthorizationStrategy(strategy)

// Allow Slave to master access control
instance.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);

{%- if jenkins.startup_quiet %}
instance.doQuietDown()
{%- endif %}

instance.save()

