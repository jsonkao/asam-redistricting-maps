import static_adapter from '@sveltejs/adapter-static';

const config = {
	kit: {
		adapter: static_adapter(),
		paths: {
			base: process.env.NODE_ENV === 'development' ? '' : '/asam-redistricting-maps',
		}
	}
};

export default config;
