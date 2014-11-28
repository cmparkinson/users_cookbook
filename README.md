# users
This cookbook is different than other 'users' cookbooks in that it relies on
the concept of user roles (webmaster, DBA, etc -- not Chef roles) to make 
decisions on whether or not a user should be present on a node.

The cookbook maintains a list of all managed users and the role(s) they have
been assigned.  Users are created and destroyed as roles are attached and
removed from nodes.

## User Roles
Users can be added to roles, which in turn can be attached to nodes.  Roles
are nothing more than groups of similar users.

## Platform
This cookbook has been tested on Ubuntu 12.04.  It should work with little-
to-no modification on other Unixes.

## `users` LWRP
The users LWRP does all the heavy lifting in this cookbook.

### Actions
- `create`
  - Creates users based on role assignment.
- `remove`
  - Removes managed users that are not assigned to a role on the node.
  - Does not operate on users not present in the user data bag.

### LWRP Attributes
- `action`
  - `create` or `remove`
- `user_data_bag`
  - The name of the data bag containing all managed users.
- `roles_data_bag`
  - The name of the data bag containing user roles and their assigned users.
- `roles`
  - An array of roles to apply to the node.
- `clear_password`
  - Clear the passwords of new users and force them to set one on first login.  This
    option is only available if the user has at least one SSH key assigned to them.
  - If you use this option, it is **HIGHLY** recommended that you disable password
    authentication in sshd_config through the `PasswordAuthentication` attribute.

## Data Bag Format
- `users`
  - `id`
    - Must match the username
  - `gid`
    - Creates a group matching the username with this GID
  - `shell`
    - The user's shell
  - `comment`
    - GECOS field
  - `home`
    - The path of the user's home directory
  - `ssh_keys`
    - An array containing public keys to add to the user's authorized_keys file

- `roles`
  - `id`
    - The role name
  - `users`
    - An array of usernames that are assigned to the role.

**Note** All user data bag items must use the username as the item ID.

## TODO
Add unix group management.
