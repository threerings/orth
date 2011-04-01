//
// $Id$

package com.threerings.orth.locus.server;

import com.threerings.orth.locus.client.LocusService;
import com.threerings.orth.locus.data.Locus;
import com.threerings.presents.data.ClientObject;

public interface LocusMaterializer
{
    void materializeLocus (ClientObject caller, Locus locus,
        LocusService.LocusMaterializationListener listener);
}
