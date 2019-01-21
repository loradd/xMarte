package se.mdh.idt.xmarte.ui.editor.model.transformation

import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement
import java.util.Optional

class UML2XMarte {

	def static dispatch CharSequence transform(Model model) 
	'''
		model «model.legalName» {
			«FOR component : model.components»
				«transform(component)»
			«ENDFOR»
		}
	'''
	

	def static dispatch CharSequence transform(Component component)
	'''
		«IF component.isHwProcessor»processor «ENDIF»
		«IF component.isHwCache»cache «ENDIF»
		«IF component.isAllocated»allocated «ENDIF»
		component «component.legalName» {
			«IF component.hasHwProcessorCores»cores = «component.hwProcessorCores»«ENDIF»
			«IF component.hasHwCacheLevel»level = «component.hwCacheLevel»«ENDIF»
			«IF component.hasAllocatedKind»kind = «component.allocatedKind»«ENDIF»
			«FOR subComponent : component.components»
				«transform(subComponent)»
			«ENDFOR»
		}
	'''

	def private static hasLegalName(NamedElement namedElement) {
		!namedElement.name.nullOrEmpty
	}

	def private static getLegalName(NamedElement namedElement) {
		if(namedElement.hasLegalName) namedElement.name else "default_name"
	}

	def private static getComponents(Element element) {
		element.ownedElements.filter(Component)
	}

	def private static isHwProcessor(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.exists["HwProcessor" == name]]
				.orElse(false)
	}
	
	def private static hasHwProcessorCores(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["HwProcessor" == name]]
				.map[component.getValue(it, "nbCores")]
				.isPresent
	}
	
	def private static getHwProcessorCores(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["HwProcessor" == name]]
				.map[component.getValue(it, "nbCores")]
				.get
	}

	def private static isHwCache(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.exists["HwCache" == name]]
				.orElse(false)
	}
	
	def private static hasHwCacheLevel(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["HwCache" == name]]
				.map[component.getValue(it, 'level')]
				.isPresent
	}
	
	def private static getHwCacheLevel(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["HwCache" == name]]
				.map[component.getValue(it, 'level')]
				.get
	}
	
	def private static isAllocated(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.exists["Allocated" == name]]
				.orElse(false)
	}
	
	def private static hasAllocatedKind(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["Allocated" == name]]
				.map[component.getValue(it, "kind")]
				.isPresent
	}
	
	def private static getAllocatedKind(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["Allocated" == name]]
				.map[component.getValue(it, "kind")]
				.get
	}
	
}
