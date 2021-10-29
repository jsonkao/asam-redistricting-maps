import static_adapter from '@sveltejs/adapter-static';

const dev = process.env.NODE_ENV === 'development';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		// hydrate the <div id="svelte"> element in src/app.html
		target: '#svelte',
		adapter: static_adapter(),
		paths: {
			base: dev ? '' : '/asam-redistricting-maps',
		}
	}
};

export default config;
