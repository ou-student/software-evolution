module Utils::CoreExtension

import String;
import lang::java::m3::Core;

/**
 * Method that checks if given entity points to an anonymous method.
 * @param entity The location to check.
 * @return 'true' if entity points to an anonymous method.
 */
public bool isAnonymous(loc entity) = isMethod(entity) && contains(entity.path, "$anonymous");

