# users
This cookbook is different than other 'users' cookbooks in that it relies on
the concept of user roles (webmaster, DBA, etc -- not Chef roles) to make 
decisions on whether or not a user login should be present on a node.

The cookbook maintains a list of all managed users and the role(s) they have
been assigned.  User logins are created and destroyed as roles are attached
and removed from nodes.

## User Roles
Users can be added to roles, which in turn can be attached to nodes.  Roles
are nothing more than groups of similar users.

## Attributes
- `node['unix_users']['roles']` an array of user roles to add to the node (default: `['admin']`)

## LWRP
The LWRP does all the heavy lifting in this cookbook.  To use it, pass the resource a data bag name
as the resource name.

**Note** All user data bag items must use the username as the item ID.

## TODO
Add unix group management.
