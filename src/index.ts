import { commands, CompleteResult, events, ExtensionContext, listManager, sources, window, workspace } from 'coc.nvim';
export async function activate(context: ExtensionContext): Promise<void> {
  window.showMessage(`ogmarks.nvim works big time! ${context.extensionPath}`);
  context.subscriptions.push(
    commands.registerCommand('ogmarks.nvim.Command', async () => {
      window.showMessage(`ogmarks.nvim Commands works!`);
      const doc = await workspace.document;
      const buf = doc.buffer;
      buf.setLines([`bufId=${buf.id}`])
    })
  );
}
