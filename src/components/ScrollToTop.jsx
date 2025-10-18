Text file: ScrollToTop.jsx
Latest content with line numbers:
1	import { useEffect } from 'react';
2	import { useLocation } from 'react-router-dom';
3	
4	export default function ScrollToTop() {
5	  const { pathname } = useLocation();
6	
7	  useEffect(() => {
8	    try {
9	      window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
10	    } catch {
11	      window.scrollTo(0, 0);
12	    }
13	  }, [pathname]);
14	
15	  return null;
16	}
17	
18	