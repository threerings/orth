//
// $Id$

package com.threerings.orth.locus.server;

import com.threerings.presents.data.ClientObject;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;

public interface LocusMaterializer
{
    void materializeLocus (ClientObject caller, Locus locus, LocusMaterializationListener listener);
}
