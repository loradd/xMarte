package se.mdh.idt.xmarte.ui.editor.model.transformation

import com.google.common.base.Strings
import java.util.Optional
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.papyrus.MARTE.MARTE_DesignModel.HRM.HwLogical.HwComputing.HwProcessor
import org.eclipse.papyrus.MARTE.MARTE_DesignModel.HRM.HwLogical.HwStorage.HwMemory.HwCache
import org.eclipse.papyrus.MARTE.MARTE_Foundations.Alloc.Allocated
import org.eclipse.papyrus.MARTE.MARTE_Foundations.Alloc.AllocationEndKind
import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Profile
import org.eclipse.uml2.uml.Stereotype
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UMLResource
import org.eclipse.xtext.xbase.lib.Functions.Function1
import se.mdh.idt.xmarte.xMarte.XComponent

import static extension java.util.Objects.nonNull

class XMarte2UML {

	static val resourceSet = new ResourceSetImpl
	static val marteResource = resourceSet.getResource(URI.createURI(
		"platform:/plugin/org.eclipse.papyrus.marte.static.profile/resources/MARTE.profile.uml"), true) as UMLResource
	static val marteProfiles = marteResource.allContents.filter(Profile)
	
	static val allocProfile = marteProfiles.findFirst[name == "Alloc"]
	static val hwComputingProfile = marteProfiles.findFirst[name == "HwComputing"]
	static val hwMemoryProfile = marteProfiles.findFirst[name == "HwMemory"]
	
	static val allocatedStereotype = allocProfile.allOwnedElements.filter(Stereotype).findFirst[name == "Allocated"]
	static val hwProcessorStereotype = hwComputingProfile.allOwnedElements.filter(Stereotype).findFirst[name == "HwProcessor"]
	static val hwCacheStereotype = hwMemoryProfile.allOwnedElements.filter(Stereotype).findFirst[name == "HwCache"] 
	
	def static void transform(Model model, Model xModel) {
		
		Optional.ofNullable(model)
			.map[appliedProfiles.filter[name == "HwMemory"].head]
			.ifPresent[model.unapplyProfile(it)]
		Optional.ofNullable(model)
			.map[appliedProfiles.filter[name == "HwComputing"].head]
			.ifPresent[model.unapplyProfile(it)]
		Optional.ofNullable(model)
			.map[appliedProfiles.filter[name == "Alloc"].head]
			.ifPresent[model.unapplyProfile(it)]		
		
		model.applyProfile(allocProfile)
		model.applyProfile(hwMemoryProfile)
		model.applyProfile(hwComputingProfile)
				
		model.name = xModel.nameOrDefault
	
		model.components.filter[component|
			xModel.XComponents.notExists[xComponent|
				component.name == xComponent.name
			]
		].forEach[destroy]

		model.components.map[component|
			component -> xModel.XComponents.findFirst[xComponent|
				component.name == xComponent.name
			]
		].filter[value.nonNull].forEach[merge]
		
		xModel.XComponents.filter[xComponent|
			model.components.notExists[component|
				component.name == xComponent.name
			]
		].forEach[model.createComponentFrom(it)]
		
	}
	
	def static void transform(Component component, XComponent xComponent) {
		
		component.name = xComponent.nameOrDefault
	
		component.components.map[packagedComponent|
			packagedComponent -> xComponent.XComponents.findFirst[xPackagedComponent|
				packagedComponent.name == xPackagedComponent.name
			]
		].filter[value.nonNull].forEach[merge]
	
		xComponent.XComponents.filter[xPackagedComponent|
			component.components.notExists[packagedComponent|
				packagedComponent.name == xPackagedComponent.name
			]
		].forEach[component.createComponentFrom(it)]
	
		component.components.filter[packagedComponent|
			xComponent.XComponents.notExists[xPackagedComponent|
				packagedComponent.name == xPackagedComponent.name
			]
		].forEach[destroy]
	
		if (xComponent.isAllocated) {
			val allocated = component.getStereotypeApplication(allocatedStereotype) as Allocated
				?: component.applyStereotype(allocatedStereotype) as Allocated
			if (xComponent.hasKind) {
				allocated.kind = AllocationEndKind.get(xComponent.kind.toString)
			}
		} else if (component.isStereotypeApplied(allocatedStereotype)) {
			component.unapplyStereotype(allocatedStereotype)
		}		
		
		if (xComponent.isHwProcessor) {
			val hwProcessor = component.getStereotypeApplication(hwProcessorStereotype) as HwProcessor
				?: component.applyStereotype(hwProcessorStereotype) as HwProcessor
			if (xComponent.hasCores) {
				hwProcessor.nbCores = xComponent.cores.toString
			}
			hwProcessor.caches.clear
			component.packagedElements.filter(Component)
				.map[subcomponent | subcomponent.stereotypeApplications.filter(HwCache).head]
				.filterNull.forEach[hwProcessor.caches.add(it)]
		} else if (component.isStereotypeApplied(hwProcessorStereotype)) {
			component.unapplyStereotype(hwProcessorStereotype)
		}
		
		if (xComponent.isHwCache) {
			val hwCache = component.getStereotypeApplication(hwCacheStereotype) as HwCache
				?: component.applyStereotype(hwCacheStereotype) as HwCache
			if (xComponent.hasLevel) {
				hwCache.level = xComponent.level.toString
			}	
		} else if (component.isStereotypeApplied(hwCacheStereotype)) {
			component.unapplyStereotype(hwCacheStereotype)
		}
		
	}
	
	def private static getNameOrDefault(NamedElement namedElement) {
		Optional.ofNullable(namedElement).map[Strings.emptyToNull(name)].orElse("default_name")
	}
	
	def private static getComponents(Element element) {
		element.ownedElements.filter(Component).toList
	}
	
	def private static getXComponents(Element element) {
		element.ownedElements.filter(XComponent).toList
	}
	
	def private static createComponent(Component component, String name) {
		component.createPackagedElement(name, UMLPackage.Literals.COMPONENT) as Component
	}
	
	def private static createComponentFrom(Component component, XComponent xComponent) {
		transform(component.createComponent(xComponent.name), xComponent)
	}
	
	def private static createComponent(Model model, String name) {
		model.createPackagedElement(name, UMLPackage.Literals.COMPONENT) as Component
	}
	
	def private static createComponentFrom(Model model, XComponent xComponent) {
		transform(model.createComponent(xComponent.name), xComponent)
	}
	
	def private static merge(Pair<Component, XComponent> components) {
		transform(components.key, components.value)
	}
	
	def private static <T> notExists(Iterable<T> iterable, Function1<? super T, Boolean> predicate) {
		return !IteratorExtensions.exists(iterable.iterator(), predicate);
	}
	
}
	