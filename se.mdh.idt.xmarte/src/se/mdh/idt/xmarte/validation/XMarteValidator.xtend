/*
 * generated by Xtext 2.10.0
 */
package se.mdh.idt.xmarte.validation

import org.eclipse.xtext.validation.Check
import se.mdh.idt.xmarte.xMarte.XAllocated
import se.mdh.idt.xmarte.xMarte.XMartePackage
import se.mdh.idt.xmarte.xMarte.XHwProcessor
import se.mdh.idt.xmarte.xMarte.XHwCache

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class XMarteValidator extends AbstractXMarteValidator {

	public static val ALLOCATED_KIND_ERROR_CODE = 'allocatedKindError'
	public static val ALLOCATED_KIND_ERROR_MESSAGE = 'Illegal attribute - Allocated stereotype required'

	public static val HWPROCESSOR_CORES_ERROR_CODE = 'hwProcessorCoresError'
	public static val HWPROCESSOR_CORES_ERROR_MESSAGE = 'Illegal attribute - HwProcessor stereotype required'

	public static val HWCACHE_LEVEL_ERROR_CODE = 'hwCacheLevelError'
	public static val HWCACHE_LEVEL_ERROR_MESSAGE = 'Illegal attribute - HwCache stereotype required'

	@Check def checkAllocatedKind(XAllocated xElement) {
		if (xElement.hasKind && !xElement.isAllocated) {
			error(
				ALLOCATED_KIND_ERROR_MESSAGE, 
				XMartePackage.Literals.XALLOCATED__HAS_KIND,
				ALLOCATED_KIND_ERROR_CODE
			)
		}
	}

	@Check def checkHwProcessorCores(XHwProcessor xElement) {
		if (xElement.hasCores && !xElement.isHwProcessor) {
			error(
				HWPROCESSOR_CORES_ERROR_MESSAGE, 
				XMartePackage.Literals.XHW_PROCESSOR__HAS_CORES,
				HWPROCESSOR_CORES_ERROR_CODE
			)
		}
	}

	@Check def check_HwCache_level(XHwCache xElement) {
		if (xElement.hasLevel && !xElement.isHwCache) {
			error(
				HWCACHE_LEVEL_ERROR_MESSAGE, 
				XMartePackage.Literals.XHW_CACHE__HAS_LEVEL,
				HWCACHE_LEVEL_ERROR_CODE)
		}
	}

}
