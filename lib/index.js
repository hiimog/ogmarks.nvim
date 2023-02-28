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
var import_coc = require("coc.nvim");
async function activate(context) {
  import_coc.window.showMessage(`ogmarks.nvim works big time! ${context.extensionPath}`);
  import_coc.events.on("TextChanged", (bufNr, changedTick) => {
    import_coc.window.showMessage(`Changed tick: ${changedTick}`);
  });
  context.subscriptions.push(
    import_coc.commands.registerCommand("ogmarks.nvim.Command", async () => {
      import_coc.window.showMessage(`ogmarks.nvim Commands works!`);
      const doc = await import_coc.workspace.document;
      const buf = doc.buffer;
      import_coc.window.showMessage(`buf.id=${buf.id}`);
    })
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  activate
});
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vc3JjL2luZGV4LnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQgeyBjb21tYW5kcywgQ29tcGxldGVSZXN1bHQsIGV2ZW50cywgRXh0ZW5zaW9uQ29udGV4dCwgbGlzdE1hbmFnZXIsIHNvdXJjZXMsIHdpbmRvdywgd29ya3NwYWNlIH0gZnJvbSAnY29jLm52aW0nO1xuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGFjdGl2YXRlKGNvbnRleHQ6IEV4dGVuc2lvbkNvbnRleHQpOiBQcm9taXNlPHZvaWQ+IHtcbiAgd2luZG93LnNob3dNZXNzYWdlKGBvZ21hcmtzLm52aW0gd29ya3MgYmlnIHRpbWUhICR7Y29udGV4dC5leHRlbnNpb25QYXRofWApO1xuICBldmVudHMub24oXCJUZXh0Q2hhbmdlZFwiLCAoYnVmTnIsIGNoYW5nZWRUaWNrKSA9PiB7XG4gICAgd2luZG93LnNob3dNZXNzYWdlKGBDaGFuZ2VkIHRpY2s6ICR7Y2hhbmdlZFRpY2t9YClcbiAgfSlcbiAgY29udGV4dC5zdWJzY3JpcHRpb25zLnB1c2goXG4gICAgY29tbWFuZHMucmVnaXN0ZXJDb21tYW5kKCdvZ21hcmtzLm52aW0uQ29tbWFuZCcsIGFzeW5jICgpID0+IHtcbiAgICAgIHdpbmRvdy5zaG93TWVzc2FnZShgb2dtYXJrcy5udmltIENvbW1hbmRzIHdvcmtzIWApO1xuICAgICAgY29uc3QgZG9jID0gYXdhaXQgd29ya3NwYWNlLmRvY3VtZW50XG4gICAgICBjb25zdCBidWYgPSBkb2MuYnVmZmVyXG4gICAgICB3aW5kb3cuc2hvd01lc3NhZ2UoYGJ1Zi5pZD0ke2J1Zi5pZH1gKVxuICAgIH0pLFxuICApO1xufVxuIl0sCiAgIm1hcHBpbmdzIjogIjs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUEsaUJBQTRHO0FBQzVHLGVBQXNCLFNBQVMsU0FBMEM7QUFDdkUsb0JBQU8sWUFBWSxnQ0FBZ0MsUUFBUSxlQUFlO0FBQzFFLG9CQUFPLEdBQUcsZUFBZSxDQUFDLE9BQU8sZ0JBQWdCO0FBQy9DLHNCQUFPLFlBQVksaUJBQWlCLGFBQWE7QUFBQSxFQUNuRCxDQUFDO0FBQ0QsVUFBUSxjQUFjO0FBQUEsSUFDcEIsb0JBQVMsZ0JBQWdCLHdCQUF3QixZQUFZO0FBQzNELHdCQUFPLFlBQVksOEJBQThCO0FBQ2pELFlBQU0sTUFBTSxNQUFNLHFCQUFVO0FBQzVCLFlBQU0sTUFBTSxJQUFJO0FBQ2hCLHdCQUFPLFlBQVksVUFBVSxJQUFJLElBQUk7QUFBQSxJQUN2QyxDQUFDO0FBQUEsRUFDSDtBQUNGOyIsCiAgIm5hbWVzIjogW10KfQo=
