resource "aws_iam_role" "role_djeg" {
  name               = "role_${var.name}"
  assume_role_policy = "${file("policies/role.json")}"
}

resource "aws_iam_role_policy" "role_policy_djeg" {
  name   = "role_policy_${var.name}"
  policy = "${file("policies/role-policy.json")}"
  role   = "${aws_iam_role.role_djeg.id}"
}

resource "aws_iam_instance_profile" "iam_instance_profile_djeg" {
  name = "iam_instance_profile_${var.name}"
  path = "/"
  role = "${aws_iam_role.role_djeg.name}"
}

data "template_file" "djeg_user_data" {
  template = "${file("files/djeg_user_data.tpl")}"

  vars {
    instancehostname = "djeg.${var.dns_zonename}"
    disk             = "${var.data_volume_mount_path}"
    djeg_version     = "${var.djeg_version}"
  }
}

resource "aws_ebs_volume" "djeg-data" {
  availability_zone = "${var.availability_zone}"
  size              = 100
  type              = "gp2"

  tags {
    Name      = "${var.name}-djeg-data"
    Backup    = "true"
    Retention = "7"
  }
}

resource "aws_instance" "djeg" {
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.sg_ci.id}"]
  ami                    = "${data.aws_ami.celebtv.id}"
  user_data              = "${data.template_file.djeg_user_data.rendered}"
  availability_zone      = "${var.availability_zone}"
  iam_instance_profile   = "${aws_iam_instance_profile.iam_instance_profile_djeg.name}"
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = "true"
  }
  tags {
    "Name" = "${var.name}.${var.dns_zonename}"
  }
}

resource "aws_eip" "djeg_elastic_ip" {
  instance = "${aws_instance.djeg.id}"
  vpc      = true
}

resource "aws_volume_attachment" "djeg-data-volume-attachment" {
  device_name  = "${var.data_volume_mount_path}"
  volume_id    = "${aws_ebs_volume.djeg-data.id}"
  instance_id  = "${aws_instance.djeg.id}"
  force_detach = true
}


output "djeg_hostname" {   value = "${aws_route53_record.celebtv-ci-djeg.name}" }

