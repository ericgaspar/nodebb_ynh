# NodeBB for YunoHost

[![Integration level](https://dash.yunohost.org/integration/nodebb.svg)](https://dash.yunohost.org/appci/app/nodebb) ![](https://ci-apps.yunohost.org/ci/badges/nodebb.status.svg) ![](https://ci-apps.yunohost.org/ci/badges/nodebb.maintain.svg)  
[![Install nodebb with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=nodebb)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allows you to install NodeBB quickly and simply on a YunoHost server.  
If you don't have YunoHost, please consult [the guide](https://yunohost.org/#/install) to learn how to install it.*

## Overview
NodeBB Forum Software is powered by Node.js and built on either a Redis or MongoDB database. It utilizes web sockets for instant interactions and real-time notifications. NodeBB has many modern features out of the box such as social network integration and streaming discussions, while still making sure to be compatible with older browsers.

**Shipped version:** 1.15.1

## Screenshots

![](https://nodebb.org/assets/gallery/responsive.png)

## Demo

* [Official demo](https://community.nodebb.org/)

## Configuration

How to configure this app: From an admin panel, a plain file with SSH, or any other way.

## Documentation

 * Official documentation: https://docs.nodebb.org/
 * YunoHost documentation: If specific documentation is needed, feel free to contribute.

## YunoHost specific features

#### Multi-user support

Are LDAP and HTTP auth supported?
Can the app be used by multiple users?

#### Supported architectures

* x86-64 - [![Build Status](https://ci-apps.yunohost.org/ci/logs/nodebb%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/nodebb/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/nodebb%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/nodebb/)

## Limitations

* Any known limitations.

## Additional information

* Other info you would like to add about this app.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/nodebb_ynh
 * App website: https://nodebb.org
 * Upstream app repository: https://github.com/NodeBB/NodeBB/
 * YunoHost website: https://yunohost.org/

---

## Developer info

Please send your pull request to the [testing branch](https://github.com/YunoHost-Apps/nodebb_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/nodebb_ynh/tree/testing --debug
or
sudo yunohost app upgrade nodebb -u https://github.com/YunoHost-Apps/nodebb_ynh/tree/testing --debug
```
