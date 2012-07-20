//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.UUID;

import com.samskivert.util.StringUtil;

import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.server.Authenticator;

import com.threerings.orth.aether.data.AetherAuthResponseData;

public abstract class AetherAuthenticator extends Authenticator
{
    /**
     * Generate a new random ident. The caller should very that this is unique amongst all users.
     */
    public static String generateIdent (int index)
    {
        UUID seed1 = UUID.randomUUID();
        UUID seed2 = UUID.randomUUID();
        return toString(seed1) + toString(seed2) + generateIdentChecksum(seed1, seed2) + index;
    }

    /**
     * Checks if a given ident is formatted correctly and its checksum matches.
     */
    public static boolean isValidIdent (String ident)
    {
        if (StringUtil.isBlank(ident) || ident.length() < 73) {
            return false;
        }

        try {
            UUID seed1 = fromString(ident.substring(0, 32));
            UUID seed2 = fromString(ident.substring(32, 64));
            Integer.parseInt(ident.substring(72));
            return ident.substring(64, 72).equalsIgnoreCase(generateIdentChecksum(seed1, seed2));

        } catch (Exception ex) {
            return false;
        }
    }

    @Override protected AuthResponseData createResponseData ()
    {
        return new AetherAuthResponseData();
    }

    /**
     * Generates a checksum for an ident.
     */
    protected static String generateIdentChecksum (UUID seed1, UUID seed2)
    {
        return StringUtil.sha1hex("" +
            seed1.getLeastSignificantBits() + seed2.getMostSignificantBits() +
            seed1.getMostSignificantBits() + seed2.getLeastSignificantBits()).substring(0, 8);
    }

    protected static UUID fromString (String str)
    {
        long l1 = fromHex(str.substring(0, 16));
        long l2 = fromHex(str.substring(16, 32));
        return new UUID(l2, l1);
    }

    protected static String toString (UUID uuid)
    {
        return toHex(uuid.getLeastSignificantBits()) +
            toHex(uuid.getMostSignificantBits());
    }

    protected static String toHex (long l)
    {
        return StringUtil.prepad(Long.toHexString(l), 16, '0');
    }

    protected static long fromHex (String hex)
    {
        // eek, java doesn't have a way to decode a 16 hex digit long?
        long i1 = Long.parseLong(hex.substring(0, 8), 16);
        long i2 = Long.parseLong(hex.substring(8, 16), 16);
        return (i1 << 32) | i2;
    }
}
