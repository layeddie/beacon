defmodule Beacon.ConfigTest do
  use ExUnit.Case, async: true

  alias Beacon.Config

  @site :my_site
  @repo Beacon.BeaconTest.Repo

  describe "registry" do
    test "returns the site config" do
      assert %Beacon.Config{
               css_compiler: Beacon.RuntimeCSS.TailwindCompiler,
               live_socket_path: "/custom_live",
               safe_code_check: false,
               site: :my_site,
               tailwind_config: tailwind_config
             } = Config.fetch!(@site)

      assert tailwind_config =~ "tailwind.config.templates.js"
    end

    test "raises for non existing site" do
      assert_raise Beacon.ConfigError, ~r/site :invalid not found/, fn ->
        Config.fetch!(:invalid)
      end
    end

    test "updates key from config" do
      assert %Config{live_socket_path: "/new_live"} = Config.update_value(:not_booted, :live_socket_path, "/new_live")
    end
  end

  describe "template_formats" do
    test "preserve default config" do
      assert %{
               template_formats: [
                 {:heex, "HEEx (HTML)"},
                 {:markdown, "Markdown (GitHub Flavored version)"}
               ]
             } = Config.new(site: :site, endpoint: :endpoint, router: :router, repo: @repo, template_formats: [])
    end

    test "merge existing config" do
      assert %{
               template_formats: [
                 {:markdown, "Markdown (GitHub Flavored version)"},
                 {:heex, "Custom HEEx description"}
               ]
             } = Config.new(site: :site, endpoint: :endpoint, router: :router, repo: @repo, template_formats: [{:heex, "Custom HEEx description"}])
    end

    test "add config" do
      assert %{
               template_formats: [
                 {:heex, "HEEx (HTML)"},
                 {:markdown, "Markdown (GitHub Flavored version)"},
                 {:custom_format, "Custom Format"}
               ]
             } = Config.new(site: :site, endpoint: :endpoint, router: :router, repo: @repo, template_formats: [{:custom_format, "Custom Format"}])
    end
  end

  describe "lifecycle" do
    test "preserve default config" do
      assert %{
               lifecycle: [
                 load_template: [{:heex, _}, {:markdown, _}],
                 render_template: [{:heex, _}, {:markdown, _}],
                 after_create_page: [],
                 after_update_page: [],
                 after_publish_page: [],
                 upload_asset: [{:thumbnail, _}]
               ]
             } = Config.new(site: :site, endpoint: :endpoint, router: :router, repo: @repo, lifecycle: [load_template: []])
    end
  end

  describe "assets" do
    test "sets defaults" do
      assert [
               {"image/jpeg",
                [
                  {:processor, _},
                  {:validations, []},
                  {:providers, [Beacon.MediaLibrary.Provider.Repo]}
                ]},
               {"image/gif",
                [
                  {:processor, _},
                  {:validations, []},
                  {:providers, [Beacon.MediaLibrary.Provider.Repo]}
                ]},
               {"image/png",
                [
                  {:processor, _},
                  {:validations, []},
                  {:providers, [Beacon.MediaLibrary.Provider.Repo]}
                ]},
               {"image/webp",
                [
                  {:processor, _},
                  {:validations, []},
                  {:providers, [Beacon.MediaLibrary.Provider.Repo]}
                ]},
               {"application/pdf",
                [
                  {:processor, _},
                  {:validations, []},
                  {:providers, [Beacon.MediaLibrary.Provider.Repo]}
                ]}
             ] = Config.new(site: :site, endpoint: :endpoint, router: :router, repo: @repo).assets
    end
  end

  describe "config_for_media_type/2" do
    test "retrieves" do
      media_type = "image/jpeg"
      config = Config.new(site: :site, endpoint: :endpoint, router: :router, repo: @repo)

      assert [
               {:processor, _},
               {:validations, []},
               {:providers, [Beacon.MediaLibrary.Provider.Repo]}
             ] = Config.config_for_media_type(config, media_type)
    end
  end
end
