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
  context.subscriptions.push(
    import_coc.commands.registerCommand("ogmarks.nvim.Command", async () => {
      import_coc.window.showMessage(`ogmarks.nvim Commands works!`);
      const doc = await import_coc.workspace.document;
      const buf = doc.buffer;
      buf.setLines([`bufId=${buf.id}`]);
    })
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  activate
});
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vc3JjL2luZGV4LnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQgeyBjb21tYW5kcywgQ29tcGxldGVSZXN1bHQsIGV2ZW50cywgRXh0ZW5zaW9uQ29udGV4dCwgbGlzdE1hbmFnZXIsIHNvdXJjZXMsIHdpbmRvdywgd29ya3NwYWNlIH0gZnJvbSAnY29jLm52aW0nO1xuZXhwb3J0IGFzeW5jIGZ1bmN0aW9uIGFjdGl2YXRlKGNvbnRleHQ6IEV4dGVuc2lvbkNvbnRleHQpOiBQcm9taXNlPHZvaWQ+IHtcbiAgd2luZG93LnNob3dNZXNzYWdlKGBvZ21hcmtzLm52aW0gd29ya3MgYmlnIHRpbWUhICR7Y29udGV4dC5leHRlbnNpb25QYXRofWApO1xuICBjb250ZXh0LnN1YnNjcmlwdGlvbnMucHVzaChcbiAgICBjb21tYW5kcy5yZWdpc3RlckNvbW1hbmQoJ29nbWFya3MubnZpbS5Db21tYW5kJywgYXN5bmMgKCkgPT4ge1xuICAgICAgd2luZG93LnNob3dNZXNzYWdlKGBvZ21hcmtzLm52aW0gQ29tbWFuZHMgd29ya3MhYCk7XG4gICAgICBjb25zdCBkb2MgPSBhd2FpdCB3b3Jrc3BhY2UuZG9jdW1lbnQ7XG4gICAgICBjb25zdCBidWYgPSBkb2MuYnVmZmVyO1xuICAgICAgYnVmLnNldExpbmVzKFtgYnVmSWQ9JHtidWYuaWR9YF0pXG4gICAgfSlcbiAgKTtcbn1cbiJdLAogICJtYXBwaW5ncyI6ICI7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7O0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBLGlCQUE0RztBQUM1RyxlQUFzQixTQUFTLFNBQTBDO0FBQ3ZFLG9CQUFPLFlBQVksZ0NBQWdDLFFBQVEsZUFBZTtBQUMxRSxVQUFRLGNBQWM7QUFBQSxJQUNwQixvQkFBUyxnQkFBZ0Isd0JBQXdCLFlBQVk7QUFDM0Qsd0JBQU8sWUFBWSw4QkFBOEI7QUFDakQsWUFBTSxNQUFNLE1BQU0scUJBQVU7QUFDNUIsWUFBTSxNQUFNLElBQUk7QUFDaEIsVUFBSSxTQUFTLENBQUMsU0FBUyxJQUFJLElBQUksQ0FBQztBQUFBLElBQ2xDLENBQUM7QUFBQSxFQUNIO0FBQ0Y7IiwKICAibmFtZXMiOiBbXQp9Cg==
