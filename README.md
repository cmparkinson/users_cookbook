# unix_users

## User Roles
Users can be added to roles, which in turn can be added to a node.  Roles are
essentially groups of users that are applied to nodes.

## Attributes
- `node['unix_users']['roles']` an array of user roles to add to the node (default: `['admin']`)

## LWRP
The LWRP does all the heavy lifting in this cookbook.  To use it, pass the resource a data bag name
as the resource name.

**Note** All user data bag items must use the username as the item ID.
