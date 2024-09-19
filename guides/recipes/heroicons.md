# Heroicons

[Heroicons](https://heroicons.com/) is part of Phoenix Core Components and used in some of the built-in Beacon components.

## Objective

Config Heroicons to render properly on your local environment and also in release packages.

##

1. Install local

## Steps

* Install the Heroicons dependency in the host application
* Configure the paths in the Tailwind config file
* Adjust the Dockerfile to copy the files

### Install dependency

Make sure the `:heroicons` dependency is added to the `mix.exs` in your application:

```elixir
{:heroicons,
  github: "tailwindlabs/heroicons",
  tag: "v2.1.1",
  sparse: "optimized",
  app: false,
  compile: false,
  depth: 1}
```

It's added by default in new Phoenix projects so you might not need to add it.

### Configure paths in your Tailwind config file

You can skip this step if you're using the default Tailwind config, ie: if there's no `:tailwind_config` in your site configuration.

But in case you're using a custom Tailwind config, you need to make sure the correct paths are set in the plugin section:

```js
plugin(function ({ matchComponents, theme }) {
  // Copy from host app deps.
  let iconsDir = path.join(__dirname, "../../heroicons/optimized")

  // Copy from release.
  // Adjust for Umbrella apps. See the Heroicons guide for more info.
  if (!fs.existsSync(iconsDir)) {
    iconsDir = path.join(__dirname, "../../../vendor/heroicons/optimized")
  }

  // rest of the file omitted...
```

See the [default config](https://github.com/BeaconCMS/beacon/blob/main/assets/tailwind.config.js) for reference or the [Tailwind Setup guide](../introduction/tailwind-setup.md) for more info.

### Copy the files into the container

You can skip this step if you're not deploying a Docker container.

The Heroicons SVG icons must be present in the container because the Tailwind compiler is executed at runtime. Assuming that you have the default Dockerfile
generated by Phoenix, open it, find the `USER nobody` line and add the following lines before it:

```Dockerfile
 # Copy heroicons svg files to used on the icon component
 RUN mkdir -p ./vendor
 COPY --from=builder --chown=nobody:root /app/deps/heroicons ./vendor/heroicons
 ```

 See the [deploy to fly.io](deploy-to-flyio.md) guide for more info.