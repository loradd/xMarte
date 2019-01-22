package se.mdh.idt.xmarte.ui.editor.model.transformation

import java.util.Optional
import org.eclipse.papyrus.MARTE.MARTE_DesignModel.HRM.HwLogical.HwComputing.HwProcessor
import org.eclipse.papyrus.MARTE.MARTE_DesignModel.HRM.HwLogical.HwStorage.HwMemory.HwCache
import org.eclipse.papyrus.MARTE.MARTE_Foundations.Alloc.Allocated
import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement

class UML2XMarte {

	def static dispatch CharSequence transform(Model model) 
	'''
		model «model.nameOrDefault» {
			«FOR component : model.components»
				«transform(component)»
			«ENDFOR»
		}
	'''
	

	def static dispatch CharSequence transform(Component component)
	'''
		«IF component.isAllocated»allocated «ENDIF»
		«IF component.isHwProcessor»processor «ENDIF»
		«IF component.isHwCache»cache «ENDIF»
		component «component.nameOrDefault» {
			«IF component.hasAllocatedKind»kind = «component.allocatedKind»«ENDIF»
			«IF component.hasHwProcessorCores»cores = «component.hwProcessorCores»«ENDIF»
			«IF component.hasHwCacheLevel»level = «component.hwCacheLevel»«ENDIF»
			«FOR subComponent : component.components»
				«transform(subComponent)»
			«ENDFOR»
		}
	'''

	def private static getNameOrDefault(NamedElement namedElement) {
		if(!namedElement.name.nullOrEmpty) namedElement.name else "default_name"
	}

	def private static getComponents(Element element) {
		element.ownedElements.filter(Component)
	}

	def private static isAllocated(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(Allocated).head]
			.isPresent
	}

	def private static isHwProcessor(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(HwProcessor).head]
			.isPresent
	}
	
	def private static isHwCache(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(HwCache).head]
			.isPresent
	}
	
	def private static hasAllocatedKind(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(Allocated).head]
			.map[kind].isPresent
	}
	
	def private static hasHwProcessorCores(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(HwProcessor).head]
			.map[nbCores].isPresent
	}
	
	def private static hasHwCacheLevel(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(HwCache).head]
			.map[level].isPresent
	}
	
	def private static getAllocatedKind(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(Allocated).head]
			.map[kind].get
	}
		
	def private static getHwProcessorCores(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(HwProcessor).head]
			.map[nbCores].get
	}
	
	def private static getHwCacheLevel(Element element) {
		Optional.ofNullable(element)
			.map[stereotypeApplications.filter(HwCache).head]
			.map[level].get
	}

}
