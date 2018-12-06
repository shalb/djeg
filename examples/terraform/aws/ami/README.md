## 1. Build the universal AMI.

```
# setup your AMS access parameters in ~/.aws

# adjust Packer variables if nedded
# vim ami.json

# build the AMI
./packer-build-ami.sh

```

## 2. Deploy the universal AMI.

```
# this will copy the AMI into all target regions stated in the script
./deploy-ami.sh <aminame>

```
