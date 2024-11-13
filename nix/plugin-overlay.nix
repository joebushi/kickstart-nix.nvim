{inputs}: final: prev: let
  mkNvimPlugin = src: pname:
    prev.pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };
in {
  nvimPlugins = {
    # Add bleeding edge plugins from the flake inputs here.
    nvim-tmux-navigation = mkNvimPlugin inputs.nvim-tmux-navigation "tmux.nvim";
    # wf-nvim = mkNvimPlugin inputs.wf-nvim "wf.nvim";
  };
}
