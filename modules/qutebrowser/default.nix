{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    qutebrowser.enable = mkOption {
      description = "Enable my customized git";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.qutebrowser.enable {
    home-manager.users.wrbbz = {
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
