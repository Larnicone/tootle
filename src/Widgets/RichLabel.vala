using Gtk;

public class Tootle.RichLabel : Gtk.Label {

    public weak Mention[]? mentions;

    public RichLabel (string text) {
        set_label (text);
        set_use_markup (true);
        activate_link.connect (open_link);
    }
    
    public static string escape_entities (string content) {
        return content
              .replace ("&", "&amp;")
              .replace ("'", "&apos;");
    }
    
    public static string restore_entities (string content) {
        return content
              .replace ("&amp;", "&")
              .replace ("&apos;", "'");
    }
    
    public new void set_label (string text) {
        base.set_markup (escape_entities (text));
    }
    
    public void wrap_words () {
        halign = Gtk.Align.START;
        single_line_mode = false;
        set_line_wrap (true);
        wrap_mode = Pango.WrapMode.WORD_CHAR;
        justify = Gtk.Justification.LEFT;
        xalign = 0;
    }
    
    public bool open_link (string url){
        if (mentions != null){
            foreach (Mention mention in mentions) {
                if (url == mention.url){
                    AccountView.open_from_id (mention.id);
                    return true;
                }
            }
        }
        
        if ("/tags/" in url){
            var encoded = url.split("/tags/")[1];
            var hashtag = Soup.URI.decode (encoded);
            
            var msg_url = "%s/api/v1/streaming/?stream=hashtag&access_token=%s&tag=%s"
                .printf (accounts.formal.instance, accounts.formal.token, encoded);
            var msg = new Soup.Message("GET", msg_url);
            
            var timeline = new TimelineView ("tag/" + hashtag);
            timeline.notificator = new Notificator (msg);
            timeline.notificator.status_added.connect ((ref status) => {
                if (settings.live_updates)
                    timeline.on_status_added (ref status);
            });
            window.open_view (timeline);
            
            return true;
        }
        
        if ("/@" in url){
            var uri = new Soup.URI (url);
            var username = url.split("/@")[1];
            
            if ("/" in username)
                StatusView.open_from_link (url);
            else
                AccountView.open_from_name ("@" + username + "@" + uri.get_host ());
            
            return true;
        }
    
        Desktop.open_uri (url);
        return true;
    }

}
