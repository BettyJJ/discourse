import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discourse-bookmark-menu",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");

    withPluginApi("0.10.1", (api) => {
      if (currentUser?.experimental_bookmark_redesign_enabled) {
        api.replacePostMenuButton("bookmark", {
          name: "bookmark-menu-shim",
          shouldRender: () => true,
          buildAttrs: (widget) => {
            return widget.attrs;
          },
        });
      }
    });
  },
};
