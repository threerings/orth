package com.threerings.orth.scene.data;

import com.samskivert.util.ByteEnum;
import com.threerings.io.Streamable;

public interface FurniAction extends ByteEnum, Streamable
{
    boolean isPortal ();

    boolean isURL ();
}
