import fs from 'fs/promises';

export async function post({ body }) {
  await fs.writeFile('static/drawings.json', body);
}

export async function get() {
  return {
    body: await fs.readFile('static/drawings.json')
  }
}