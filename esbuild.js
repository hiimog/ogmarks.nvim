/* eslint-disable @typescript-eslint/no-var-requires */
async function start(watch) {
  await require('esbuild').build({
    entryPoints: ['/home/og/src/ogmarks.nvim/src/index.ts'],
    bundle: true,
    watch,
    minify: false,
    sourcemap: 'inline',
    mainFields: ['module', 'main'],
    external: ['coc.nvim'],
    platform: 'node',
    target: 'node10.12',
    outfile: 'lib/index.js',
  });
}

let watch = false;
if (process.argv.length > 2 && process.argv[2] === '--watch') {
  console.log('watching...');
  watch = {
    onRebuild(error) {
      if (error) {
        console.error('watch build failed:', error);
      } else {
        console.log('watch build succeeded');
      }
    },
  };
}

start(watch).catch((e) => {
  console.error(e);
});
