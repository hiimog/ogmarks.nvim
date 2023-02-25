"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/index.ts
var src_exports = {};
__export(src_exports, {
  activate: () => activate
});
module.exports = __toCommonJS(src_exports);
var import_coc2 = require("coc.nvim");

// src/lists.ts
var import_coc = require("coc.nvim");
var DemoList = class extends import_coc.BasicList {
  constructor(nvim) {
    super(nvim);
    this.name = "demo_list";
    this.description = "CocList for ogmarks.nvim";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", (item) => {
      import_coc.window.showMessage(`${item.label}, ${item.data.name}`);
    });
  }
  async loadItems(context) {
    return [
      {
        label: "ogmarks.nvim list item 1",
        data: { name: "list item 1" }
      },
      {
        label: "ogmarks.nvim list item 2",
        data: { name: "list item 2" }
      }
    ];
  }
};

// src/index.ts
async function activate(context) {
  import_coc2.window.showMessage(`ogmarks.nvim works!`);
  context.subscriptions.push(
    import_coc2.commands.registerCommand("ogmarks.nvim.Command", async () => {
      import_coc2.window.showMessage(`ogmarks.nvim Commands works!`);
    }),
    import_coc2.listManager.registerList(new DemoList(import_coc2.workspace.nvim)),
    import_coc2.sources.createSource({
      name: "ogmarks.nvim completion source",
      doComplete: async () => {
        const items = await getCompletionItems();
        return items;
      }
    }),
    import_coc2.workspace.registerKeymap(
      ["n"],
      "ogmarks.nvim-keymap",
      async () => {
        import_coc2.window.showMessage(`registerKeymap`);
      },
      { sync: false }
    ),
    import_coc2.workspace.registerAutocmd({
      event: "InsertLeave",
      request: true,
      callback: () => {
        import_coc2.window.showMessage(`registerAutocmd on InsertLeave`);
      }
    })
  );
}
async function getCompletionItems() {
  return {
    items: [
      {
        word: "TestCompletionItem 1",
        menu: "[ogmarks.nvim]"
      },
      {
        word: "TestCompletionItem 2",
        menu: "[ogmarks.nvim]"
      }
    ]
  };
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  activate
});
