
package ecommander.extra._generated;

import java.io.File;
import ecommander.controllers.AppContext;
import ecommander.model.item.Item;
import ecommander.model.item.ItemTypeRegistry;

public class Abstract_page
    extends Item
{

    private final static String _ITEM_TYPE_NAME = "abstract_page";

    private Abstract_page(Item item) {
        super(item);
    }

    public static Abstract_page get(Item item) {
        boolean isCompatible = ItemTypeRegistry.getItemPredecessorsExt(item.getTypeName()).contains(_ITEM_TYPE_NAME);
        if (!isCompatible) {
            throw new ClassCastException(("Wrapper 'abstract_page' can not be created around '"+(item.getTypeName()+"' object")));
        }
        return new Abstract_page(item);
    }

    public static Abstract_page newChild(Item parent) {
        return get(newChildItem(ItemTypeRegistry.getItemType(_ITEM_TYPE_NAME), parent));
    }

    public void set_header(String value) {
        setValue("header", value);
    }

    public String get_header() {
        return getStringValue("header");
    }

    public String getDefault_header(String defaultVal) {
        return getStringValue("header", defaultVal);
    }

    public boolean contains_header(String value) {
        return containsValue("header", value);
    }

    public void set_header_pic(File value) {
        setValue("header_pic", value);
    }

    public File get_header_pic() {
        return getFileValue("header_pic", AppContext.getFilesDirPath());
    }

    public boolean contains_header_pic(File value) {
        return containsValue("header_pic", value);
    }

}
