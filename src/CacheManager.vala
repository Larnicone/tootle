using Gdk;
using GLib;

public class Tootle.CacheManager : GLib.Object{

    private static CacheManager _instance;
    public static CacheManager instance{
        get{
            if(_instance == null)
                _instance = new CacheManager();
            return _instance;
        }
    }
    
    private static string path_images;

    construct{
        path_images = GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD);
    }

    public CacheManager(){
        Object ();
    }
    
    public void load_image (string url, Granite.Widgets.Avatar avatar){
        var msg = new Soup.Message("GET", url);
        msg.finished.connect(()=>{
                uint8[] buf = msg.response_body.data;
                var loader = new PixbufLoader();
                loader.set_size (32,32);
                loader.write(buf);
                loader.close();
                var pixbuf = loader.get_pixbuf ();
                
                avatar.pixbuf = pixbuf;
        });
        NetManager.instance.queue(msg, (sess, mess) => {});
    }

}