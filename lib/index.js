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
      import_coc.window.showMessage(`buf.id=${buf.id}`);
    })
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  activate
});
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsiLi4vc3JjL2luZGV4LnRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJpbXBvcnQgeyBjb21tYW5kcywgQ29tcGxldGVSZXN1bHQsIEV4dGVuc2lvbkNvbnRleHQsIGxpc3RNYW5hZ2VyLCBzb3VyY2VzLCB3aW5kb3csIHdvcmtzcGFjZSB9IGZyb20gJ2NvYy5udmltJztcbmV4cG9ydCBhc3luYyBmdW5jdGlvbiBhY3RpdmF0ZShjb250ZXh0OiBFeHRlbnNpb25Db250ZXh0KTogUHJvbWlzZTx2b2lkPiB7XG4gIHdpbmRvdy5zaG93TWVzc2FnZShgb2dtYXJrcy5udmltIHdvcmtzIGJpZyB0aW1lISAke2NvbnRleHQuZXh0ZW5zaW9uUGF0aH1gKTtcbiAgXG4gIGNvbnRleHQuc3Vic2NyaXB0aW9ucy5wdXNoKFxuICAgIGNvbW1hbmRzLnJlZ2lzdGVyQ29tbWFuZCgnb2dtYXJrcy5udmltLkNvbW1hbmQnLCBhc3luYyAoKSA9PiB7XG4gICAgICB3aW5kb3cuc2hvd01lc3NhZ2UoYG9nbWFya3MubnZpbSBDb21tYW5kcyB3b3JrcyFgKTtcbiAgICAgIGNvbnN0IGRvYyA9IGF3YWl0IHdvcmtzcGFjZS5kb2N1bWVudFxuICAgICAgY29uc3QgYnVmID0gZG9jLmJ1ZmZlclxuICAgICAgd2luZG93LnNob3dNZXNzYWdlKGBidWYuaWQ9JHtidWYuaWR9YClcbiAgICB9KSxcbiAgKTtcbn1cbiJdLAogICJtYXBwaW5ncyI6ICI7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7O0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBLGlCQUFvRztBQUNwRyxlQUFzQixTQUFTLFNBQTBDO0FBQ3ZFLG9CQUFPLFlBQVksZ0NBQWdDLFFBQVEsZUFBZTtBQUUxRSxVQUFRLGNBQWM7QUFBQSxJQUNwQixvQkFBUyxnQkFBZ0Isd0JBQXdCLFlBQVk7QUFDM0Qsd0JBQU8sWUFBWSw4QkFBOEI7QUFDakQsWUFBTSxNQUFNLE1BQU0scUJBQVU7QUFDNUIsWUFBTSxNQUFNLElBQUk7QUFDaEIsd0JBQU8sWUFBWSxVQUFVLElBQUksSUFBSTtBQUFBLElBQ3ZDLENBQUM7QUFBQSxFQUNIO0FBQ0Y7IiwKICAibmFtZXMiOiBbXQp9Cg==
