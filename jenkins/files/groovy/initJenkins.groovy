{%- from "jenkins/map.jinja" import jenkins with context %}
import jenkins.model.*
import hudson.security.*

def instance       = Jenkins.getInstance()
def admin_user     = "{{ jenkins.get('admin_username')}}"
def admin_password = "{{ jenkins.get('admin_password')}}"
def hudsonRealm    = new hudson.security.HudsonPrivateSecurityRealm(false)
def strategy

if(hudsonRealm.loadUserByUsername(admin_user))
{
  println ( "admin user " + admin_user + " exists, skipping setup")
} else {
  hudsonRealm.createAccount(admin_user, admin_password)
  instance.setSecurityRealm(hudsonRealm)

  if (Jenkins.instance.getPluginManager().getPlugin("matrix-auth"))
  {
    println("initJenkins.groovy: Using matrix-auth plugin to create admin user " + admin_user)
    strategy = new hudson.security.GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, admin_user)
  }else{
    println("initJenkins.groovy: matrix-auth is not installed - using global auth to create admin user " + admin_user)
    strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
  }

  instance.setAuthorizationStrategy(strategy)
}

{%- if jenkins.startup_quiet %}
instance.doQuietDown()
{%- endif %}
instance.save()

