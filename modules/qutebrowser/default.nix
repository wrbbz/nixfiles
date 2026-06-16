{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkOption;
  nixosConfig = config;
in {
  options.my-config = {
    qutebrowser.enable = mkOption {
      description = "Enable qutebrowser";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf nixosConfig.my-config.qutebrowser.enable {
    home-manager.users.wrbbz =
      # Function form so we can reference config.sops.{placeholder,templates}
      { config, lib, ... }:
      {
        sops.secrets."qb_excorp_atlassian" = {
          sopsFile = ../../secrets/hosts.yaml;
          key = "excorp_atlassian";
        };

        sops.secrets."qb_excorp_gitlab" = {
          sopsFile = ../../secrets/hosts.yaml;
          key = "excorp_gitlab";
        };

        sops.secrets."qb_excorp_ff" = {
          sopsFile = ../../secrets/hosts.yaml;
          key = "excorp_ff";
        };

        sops.secrets."qb_spbpu_gitlab" = {
          sopsFile = ../../secrets/hosts.yaml;
          key = "spbpu_gitlab";
        };

        sops.templates."qutebrowser-quickmarks" = {
          path = "${config.xdg.configHome}/qutebrowser/quickmarks";
          content = ''
            exit https://${config.sops.placeholder."qb_excorp_gitlab"}
            exff https://${config.sops.placeholder."qb_excorp_ff"}
            lab215 https://${config.sops.placeholder."qb_spbpu_gitlab"}
            j https://${config.sops.placeholder."qb_excorp_atlassian"}/jira/for-you
            jpt https://${config.sops.placeholder."qb_excorp_atlassian"}/jira/software/c/projects/PTMT/boards/79
            jpe https://${config.sops.placeholder."qb_excorp_atlassian"}/jira/software/c/projects/PE/boards/134
            jinc https://${config.sops.placeholder."qb_excorp_atlassian"}/jira/software/c/projects/PE/boards/288
            jadr https://${config.sops.placeholder."qb_excorp_atlassian"}/jira/software/c/projects/PE/boards/420
            c https://${config.sops.placeholder."qb_excorp_atlassian"}/wiki/home
          '';
        };

        sops.templates."qutebrowser-private" = {
          content = ''
            c.url.searchengines['jql'] = 'https://${config.sops.placeholder."qb_excorp_atlassian"}/issues?jql=text+~+"{}"'
            c.url.searchengines['j'] = 'https://${config.sops.placeholder."qb_excorp_atlassian"}/browse/{}'
            c.url.searchengines['c'] = 'https://${config.sops.placeholder."qb_excorp_atlassian"}/wiki/search?text={}'
            c.url.searchengines['exit'] = 'https://${config.sops.placeholder."qb_excorp_gitlab"}/search?search={}'
            c.url.searchengines['exff'] = 'https://${config.sops.placeholder."qb_excorp_ff"}/projects/default?search={}'
            c.url.searchengines['lab215'] = 'https://${config.sops.placeholder."qb_spbpu_gitlab"}/search?search={}'
          '';
        };

        programs.qutebrowser = {
          enable = true;
          aliases = {
            "arch" = "open https://archlinux.org";
            "ff" = "spawn firefox {url}";
            "mpv" = "spawn mpv {url}";
            "proxy-gateway" = "set content.proxy socks://localhost:8118/";
            "proxy-off" = "set content.proxy system";
            "q" = "quit";
            "stig-add" = "spawn stig add {url}";
            "tor" = "spawn tor-browser {url}";
            "w" = "session-save";
            "wq" = "quit --save";
            "yt" = "open https://youtube.com/feed/subscriptions";
            "nq" = "open https://nixpkgs-update-logs.nix-community.org/~supervisor/queue.html";
          };
          searchEngines = {
            DEFAULT = "https://duckduckgo.com/?q={}";
            airbnb = "https://www.airbnb.com/s/{}/";
            ali = "https://ru.aliexpress.com/wholesale?SearchText={}";
            amazon = "https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords={}";
            aur = "https://aur.archlinux.org/packages/?O=0&K={}";
            avito = "https://www.avito.ru/sankt-peterburg?q={}";
            aw = "https://wiki.archlinux.org/?search={}";
            booking = "https://www.booking.com/searchresults.ru.html?&ss={}";
            crates = "https://crates.io/search?q={}";
            d = "https://duckduckgo.com/?q={}";
            do = "https://www.digitalocean.com/community/search?q={}";
            docsrs = "https://docs.rs/releases/search?query={}";
            dh = "https://hub.docker.com/search?q={}&type=image";
            ebay = "https://www.ebay.com/sch/items/?_nkw={}";
            g = "https://www.google.com/search?hl=en&q={}";
            gl = "https://gitlab.com/search?search={}";
            gh = "https://github.com/search?utf8=/%E2%9C%93&q={}&type=";
            ghm = "https://github.com/marketplace?query={}";
            gmaps = "https://www.google.ru/maps/search/{}";
            gw = "https://wiki.gentoo.org/?search={}";
            hoogle = "https://hoogle.haskell.org/?hoogle={}";
            hm = "https://mipmip.github.io/home-manager-option-search/?query={}";
            ikea = "https://www.ikea.com/ru/ru/search/?query={}";
            imdb = "http://www.imdb.com/find?ref_=nv_sr_fn&q={}&s=all";
            librs = "https://lib.rs/search?q={}";
            maps = "https://openstreetmap.org/search?query={}";
            man = "https://man.archlinux.org/man/{}";
            market = "https://market.yandex.ru/search?cvredirect=2&text={}&local-offers-first=1";
            netflix = "https://www.netflix.com/search?q={}";
            nix = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
            nixo = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=options&query={}";
            nw = "https://nixos.wiki/index.php?search={}&go=Go";
            pac = "https://www.archlinux.org/packages/?q={}";
            paca = "https://www.archlinuxarm.org/packages/?q={}";
            pacd = "https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords={}";
            pacf = "https://apps.fedoraproject.org/packages/s/{}";
            pacu = "https://packages.ubuntu.com/search?keywords={}&searchon=sourcenames";
            pochta = "https://www.pochta.ru/tracking#{}";
            pdb = "https://www.protondb.com/search?q={}";
            pulumi = "https://www.pulumi.com/docs/#stq={}&stp=1";
            pulreg = "https://www.pulumi.com/registry/packages/{}";
            rcgo = "https://rc-go.ru/search/?s={}";
            rstd = "https://doc.rust-lang.org/std/?search={}";
            reddit = "https://reddit.com/search?q={}";
            r = "https://reddit.com/r/{}";
            spotify = "https://open.spotify.com/search/{}";
            tpb = "https://thepiratebay.org/search/{}";
            unixporn = "https://www.reddit.com/r/unixporn/search?q={}&restrict_sr=on";
            w = "https://en.wikipedia.org/?search={}";
            ya = "https://yandex.ru/search/?lr=2&text={}";
            yamaps = "https://yandex.ru/maps/2/saint-petersburg/search/{}/";
            yt = "https://youtube.com/results?search_query={}";
            "я" = "https://yandex.ru/search/?lr=2&text={}";
          };
          settings = {
            editor = {
              command = ["alacritty" "-e" "vim" "{}"];
              encoding = "utf-8";
            };
            url = {
              start_pages = "qute://start";
              default_page = "qute://start";
              open_base_url = true;
            };
            downloads = {
              location.directory = "~/Downloads";
              location.prompt = false;
            };
            content.notifications.enabled = false;
          };
          extraConfig = ''
            config.source('${config.sops.templates."qutebrowser-private".path}')
            # Gruvbox dark colours
            config.source('dark-gruvbox.py')
          '';
        };
        home.file = {
          "dark-gruvbox.py" = {
            target = ".config/qutebrowser/dark-gruvbox.py";
            source = ./dark-gruvbox.py;
          };
        };
      };
  };
}
