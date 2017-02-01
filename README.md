# <a name="title"></a> Kitchen::Lxd

A Test Kitchen Driver for Lxd.

## <a name="requirements"></a> Requirements

### Lxd

Lxd version of 2.3 (the one where "lxc network" commands were introduced) or higher is required for
this driver which means that a native package must be installed on the system running Test Kitchen.

## <a name="installation"></a> Installation and Setup

Install using command line:

```bash
gem install kitchen-lxd
```

## <a name="config"></a> Configuration

Available options:

- image
- container
- require_chef_omnibus

### image

Define from which lxd image the container will be created.

```yaml
---
driver:
  image: ubuntu/xenial/amd64
```

The default is value of `platform name`.

```yaml
---
platforms:
  - name: kitchen-xenial64
```

In this case: 'kitchen-xenial64', expecting to have an lxd image with this name locally.

### container

Created container name.

```yaml
---
driver:
  container_name: my_name
```

The default is value of `kitchen instance name`.

```yaml
---
platforms:
  - name: kitchen-xenial64

suites:
  - name: webserver
```

In this case: 'webserver-kitchen-xenial64'.

### <a name="config-require-chef-omnibus"></a> require\_chef\_omnibus

Determines whether or not a Chef [Omnibus package][chef_omnibus_dl] will be
installed. There are several different behaviors available:

- `true` - the latest release will be installed. Subsequent converges
  will skip re-installing if chef is present.
- `latest` - the latest release will be installed. Subsequent converges
  will always re-install even if chef is present.
- `<VERSION_STRING>` (ex: `10.24.0`) - the desired version string will
  be passed the the install.sh script. Subsequent converges will skip if
  the installed version and the desired version match.
- `false` or `nil` - no chef is installed.

The default value is unset, or `nil`.

## <a name="development"></a> Development

- Source hosted at [GitHub][repo]
- Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [ZeroTurnaround][author].

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/zeroturnaround
[issues]:           https://github.com/zeroturnaround/kitchen-lxd/issues
[license]:          https://github.com/zeroturnaround/kitchen-lxd/blob/master/LICENSE
[repo]:             https://github.com/zeroturnaround/kitchen-lxd
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  http://www.chef.io/chef/install/
