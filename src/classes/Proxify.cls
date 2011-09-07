public with sharing class Proxify {

	public Boolean v_cache {
		get {
			if(ApexPages.currentPage().getParameters().containsKey('cache') && ApexPages.currentPage().getParameters().get('cache') != '' && ApexPages.currentPage().getParameters().get('cache') != 'null') {
				v_cache = Boolean.valueOf(ApexPages.currentPage().getParameters().get('cache'));
			}
			return v_cache;
		}
		set;
	}
	
	public Integer v_expires {
		get {
			if(ApexPages.currentPage().getParameters().containsKey('expires')) {
				if(ApexPages.currentPage().getParameters().get('expires') == '' || ApexPages.currentPage().getParameters().get('expires') == 'null') v_expires = 0;
				else v_expires = Integer.valueOf(ApexPages.currentPage().getParameters().get('expires'));
			}
			return v_expires;
		}
		set;
	}

	public String v_url {
		get {
			if(v_url == null && ApexPages.currentPage().getParameters().containsKey('url')) {
				v_url = ApexPages.currentPage().getParameters().get('url');
			}
			return v_url;
		}
		set;
	}
	
	public String v_contentType {
		get {
			if(v_contentType == null || v_contentType == '') {
				if(ApexPages.currentPage().getParameters().containsKey('contentType')) {
					v_contentType = ApexPages.currentPage().getParameters().get('contentType');
					if(v_contentType == '') findContentType();
				}
				else {
					findContentType();
				}
			}
			return v_contentType;
		}
		set;
	}

	public String link {
		get {
			PageReference p = Page.Proxify;
			return p.getUrl() + '?url=' + v_url + '&contentType=' + v_contentType + '&cache=' + v_cache + '&expires=' + v_expires; 
		}
	}

	public String output { get; set; }

	public Proxify() {
		v_cache = false;
		v_expires = 0;
	}

	public void init() {
		
		HttpRequest request = new HttpRequest();
		request.setEndpoint(v_url);
		request.setMethod('GET');
		
		Http h = new Http();
		HttpResponse response = h.send(request);
		output = response.getBody();
		
	}

	private void findContentType() {
		
		system.debug('*** findContentType::url' + v_url);
		
		if(v_url == null) return;
		else if(v_url.endsWith('.css')) v_contentType = 'text/css';
		else if(v_url.endsWith('.js')) v_contentType = 'text/javascript';
		else if(v_url.endsWith('.xml')) v_contentType = 'text/xml';
		else if(v_url.endsWith('.json')) v_contentType = 'text/plain';		
		else v_contentType = 'text/html';
		
	}
	
	public static testmethod void test() {
		
		PageReference p = new PageReference('/');
		Test.setCurrentPage(p);
		
		ApexPages.currentPage().getParameters().put('cache', 'true');
		ApexPages.currentPage().getParameters().put('expires', '600');
		
		Proxify s = new Proxify();
		
		system.assertEquals(s.v_cache, true);
		system.assertEquals(s.v_expires, 600);
		
		ApexPages.currentPage().getParameters().put('url', '/foo.html');
		system.assertNotEquals(s.link, null);
		system.assertEquals(s.v_url, '/foo.html');
		system.assertEquals(s.v_contentType, 'text/html');
		
		ApexPages.currentPage().getParameters().put('contentType','');
		s = new Proxify();
		system.assertEquals(s.v_contentType, 'text/html');
		
		ApexPages.currentPage().getParameters().put('url', '/foo.css');
		s = new Proxify();
		system.assertEquals(s.v_contentType, 'text/css');
		
		ApexPages.currentPage().getParameters().put('url', '/foo.js');
		s = new Proxify();  
		system.assertEquals(s.v_contentType, 'text/javascript');
		
		ApexPages.currentPage().getParameters().put('url', '/foo.xml');
		s = new Proxify();
		system.assertEquals(s.v_contentType, 'text/xml');
		
		ApexPages.currentPage().getParameters().put('url', '/foo.json');
		s = new Proxify();
		system.assertEquals(s.v_contentType, 'text/plain');
		
	}

}