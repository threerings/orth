// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.whirled.spot.data.Portal;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.room.data.OrthLocation;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class OrthPortal extends Portal
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var dest :OrthLocation;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        dest = ins.readObject(OrthLocation);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(dest);
    }

// GENERATED STREAMING END


    /**
     * Constructs a portal from the supplied furni data record.
     */
    public function OrthPortal (furni :FurniData = null)
    {
        if (furni == null) {
            return;
        }

        var vals :Array = furni.splitActionData();
        portalId = furni.id;
        loc = furni.loc;
        targetSceneId = int(vals[0]);
        targetPortalId = -1;

        // parse our destination location if we have one
        if (vals.length > 5) {
            var tdest :OrthLocation = new OrthLocation();
            tdest.x = Number(vals[1]);
            tdest.y = Number(vals[2]);
            tdest.z = Number(vals[3]);
            tdest.orient = int(vals[4]);
            // it's possible that someone named their room something wacky and fooled our parser,
            // so validate the data before we actually use it
            if (tdest.x != 0 || tdest.y != 0 || tdest.z != 0 || tdest.orient != 0) {
                dest = tdest;
            }
        }
    }

    // documentation inherited from interface Cloneable
    override public function clone () :Object
    {
        var p :OrthPortal = (super.clone() as OrthPortal);
        p.dest = dest;
        return p;
    }


// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
