import { main as quicktype } from 'quicktype';

async function generateTypesFiles() {
  const schemaAndTypesPaths = process.argv.slice(2);

  if (schemaAndTypesPaths.length % 2 !== 0) {
    throw new Error('Expected pairs of schema and TypeScript output paths.');
  }

  for (let index = 0; index < schemaAndTypesPaths.length; index += 2) {
    const schemaPath = schemaAndTypesPaths[index];
    const typesPath = schemaAndTypesPaths[index + 1];

    await quicktype({
      out: typesPath,
      quiet: true,
      rendererOptions: { 'just-types': true },
      src: [schemaPath],
      srcLang: 'schema',
    });
  }
}

generateTypesFiles().catch((error) => {
  const message =
    error instanceof Error ? error.stack || error.message : String(error);
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
