# Networking Module

Creates the VPC, public and private subnets, Internet Gateway, and route tables used by The Social Network.

Private subnets intentionally have no default internet route or NAT Gateway. This keeps the initial development cost low. Add outbound connectivity only when a resource in a private subnet requires it.

The module creates one public and one private subnet for each supplied Availability Zone.
