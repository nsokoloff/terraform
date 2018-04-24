variable "auth_token" {}

provider "rundeck" {
  url        = "https://mc.netbyte.org/"
  auth_token = "${var.auth_token}"
}

resource "rundeck_project" "anvils" {
  name        = "anvils"
  description = "Application for managing Anvils"

  ssh_key_storage_path = "${rundeck_private_key.anvils.path}"

  resource_model_source {
    type = "url"

    config = {
      format                    = "resourcexml"
      file                      = "/var/rundeck/projects/anvils/ect/resources.xml"
      includeServerNode         = "true"
      generateFileAutomatically = "true"
      cache                     = "false"
      url                       = "https://netbyte.org/resources.xml"
    }
  }
}

resource "rundeck_job" "minecraft_op-deop" {
  option = {
    name                      = "op-deop"
    default_value             = "op"
    value_choices             = ["deop,op"]
    require_predefined_choice = "true"
    required                  = "true"
  }

  option = {
    name                      = "person"
    default_value             = "omoroka"
    value_choices             = ["omoroka,motivo"]
    require_predefined_choice = "true"
    required                  = "true"
  }

  name                           = "minecraft_op-deop"
  project_name                   = "${rundeck_project.anvils.name}"
  node_filter_query              = "minecraft"
  description                    = "op,deop someone"
  node_filter_exclude_precedence = "true"
  #nodes_selected_by_default      = true

  command {
    shell_command = "/usr/local/bin/op.sh $RD_OPTION_OP_DEOP $RD_OPTION_PERSON"
  }
}

resource "rundeck_private_key" "anvils" {
  path         = "anvils/id_rsa"
  key_material = "${file("ssh/id_rsa")}"
}

resource "rundeck_public_key" "anvils" {
  path         = "anvils/id_rsa.pub"
  key_material = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6qkde52N5HsPFJikptLACscHYfPh48lFuZ3heJDg1Z3L44K9o/CfMTmfs6EdlB8ewWLIV63vS8fYm7NAZi/JLaySxTGjrX4fQjnSwcEwjaZd91jpdDQ9+t33xAGrqu56wkg+y03AnKKeT/LoZ0ihYOtakLtK8/e8t49BLOzIF8z9KIIiSTjqEr39CzzNAlK+77KR2z1/ZICHMytVU1Ggax1in6a7EPmjir44werXeMdLlbrVCWGalUiqYgyHz57K91C/D+hy1yWPwhQDqIuurNgTefofxDsxcgrEGJ4ive8invYLpzme1iEW2F3mIbD4ivl0kEld3d6hX4abUvaf/ minecraft@netbyte.org"
}
