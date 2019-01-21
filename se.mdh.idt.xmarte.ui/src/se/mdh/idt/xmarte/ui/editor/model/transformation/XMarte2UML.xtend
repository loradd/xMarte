package se.mdh.idt.xmarte.ui.editor.model.transformation

import com.google.common.base.Strings
import java.util.Optional
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Element
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Profile
import org.eclipse.uml2.uml.Stereotype
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UMLResource
import org.eclipse.xtext.xbase.lib.Functions.Function1
import se.mdh.idt.xmarte.xMarte.AllocationEndKind
import se.mdh.idt.xmarte.xMarte.XComponent

import static extension java.util.Objects.nonNull

class XMarte2UML {

	/** Resource set **/
	private static val resourceSet = new ResourceSetImpl
	/** MARTE profile URI **/
	private static val marteProfileURI = URI.createURI(
		"platform:/plugin/org.eclipse.papyrus.marte.static.profile/resources/MARTE.profile.uml")
	/** MARTE profile resource **/
	private static val marteProfileResource = resourceSet.getResource(marteProfileURI, true) as UMLResource
	/** MARTE Profile **/
	private static val marteProfile = marteProfileResource.contents.findFirst [ containedElement |
		containedElement instanceof Profile && "MARTE".equals((containedElement as Profile).name)
	] as Profile

	/** Supported profiles **/
	private static val profiles = {
		newHashMap( 
			/* MARTE_Foundations Profile (Allocated) */
			Pair.of("Alloc",
				marteProfile.allOwnedElements.findFirst[ ownedElement |
					ownedElement instanceof Profile && "Alloc".equals((ownedElement as Profile).name)
				] as Profile
			),	
			/* HwComputing Profile (HwProcessor) */ 
			Pair.of("HwComputing",
				marteProfile.allOwnedElements.findFirst [ ownedElement |
					ownedElement instanceof Profile && "HwComputing".equals((ownedElement as Profile).name)
				] as Profile), 
			/* HwMemory Profile (HwCache) */ 
			Pair.of("HwMemory", marteProfile.allOwnedElements.findFirst [ ownedElement |
				ownedElement instanceof Profile && "HwMemory".equals((ownedElement as Profile).name)
			] as Profile))
	};
	
	
	/** Supported stereotypes **/
	private static val stereotypes = {
		newHashMap( 
			/* Allocated Stereotype */
			Pair.of("Allocated",
				profiles.get("Alloc").allOwnedElements.findFirst[ownedElement|
					ownedElement instanceof Stereotype && "Allocated".equals((ownedElement as Stereotype).name)
				] as Stereotype
			),
			/* HwProcessor Stereotype */ 
			Pair.of("HwProcessor",
				XMarte2UML.profiles.get("HwComputing").allOwnedElements.findFirst [ ownedElement |
					ownedElement instanceof Stereotype && "HwProcessor".equals((ownedElement as Stereotype).name)
				] as Stereotype), 
			/* HwCache Stereotype */ 
			Pair.of("HwCache",
				XMarte2UML.profiles.get("HwMemory").allOwnedElements.findFirst [ ownedElement |
					ownedElement instanceof Stereotype && "HwCache".equals((ownedElement as Stereotype).name)
				] as Stereotype))
	};

	/** Used Profiles (keeps track of the required profiles throughout the transformation) **/
	// private static val appliedProfiles = newHashSet()

	/**
	 * [RULE] Model
	 **/
	def static void transform(Model model, Model xModel) {
		
		/* Reset applied profiles */
		model.appliedProfiles.toList.forEach[profile|model.unapplyProfile(profile)]

		/* Update name **/
		model.name = xModel.nameOrDefault

		/* Retrieve components */
		val components = model.components
		
		/* Retrieve xComponents */
		val xComponents = xModel.XComponents
		
		/* Retrieve shared components (both UML and MarText models) */
		val preservedComponents = components.map[component|
			component -> xComponents.findFirst[xComponent|
				component.qualifiedName.equals(xComponent.qualifiedName)
			] ?: null
		].filter[value.nonNull].toList
		
		/* Retrieve inserted components (MarText model only) */
		val insertedComponents = xComponents.filter[xComponent|
			!components.exists[component|component.qualifiedName.equals(xComponent.qualifiedName)]
		].toList
		
		/* Retrieve removed components (UML model only) */
		val removedComponents = components.filter[component|
			!xComponents.exists[xComponent|
				component.qualifiedName.equals(xComponent.qualifiedName)
			]
		].toList
		
		/* Delete removed components */
		removedComponents.forEach[destroy]

		/* Update shared components */
		preservedComponents.forEach[merge]

		/* Create inserted components */
		insertedComponents.forEach[model.createComponentFrom(it)]

	}

	/**
	 * [RULE] Component
	 **/
	def static void transform(Component component, XComponent xComponent) {
		
		/* Update name */
		component.name = xComponent.nameOrDefault
		
		/* HwProcessor Stereotype */
		if (xComponent.hwProcessor) {
			/* Apply HwComputing Profile (if not applied) */
			component.model.applyHwComputing	
			/* Apply HwProcessor Stereotype (if not applied) */
			component.applyHwProcessor
			/* HwProcessor.cores Property */
			if (xComponent.hwProcessorCores) {
				/* Set HwProcessor.cores */
				component.hwProcessorCores = xComponent.hwProcessorCoresValue
			}
		} else {
			/* Unapply HwProcessor Stereotype (if applied) */
			component.unapplyHwProcessor
		}
		/* HwCache Stereotype */
		if (xComponent.hwCache) {
			/* Apply HwMemory Profile (if not applied) */
			component.model.applyHwMemory
			/* Apply HwCache Stereotype (if not applied) */
			component.applyHwCache
			/* HwCache.level Property */
			if (xComponent.hwCacheLevel) {
				/* Set HwCache.level */
				component.hwCacheLevel = xComponent.hwCacheLevelValue
			}
		} else {
			/* Unapply HwCache Stereotype (if applied) */
			component.unapplyHwCache
		}
		/* Allocated Stereotype */
		if (xComponent.allocated) {
			/* Apply Alloc Profile (if not applied) */
			component.model.applyAlloc
			/* Apply Allocated Stereotype (if not applied) */
			component.applyAllocated
			/* Allocated.kind Property */
			if (xComponent.allocatedKind) {
				/* Set Allocated.kind */
				component.allocatedKind = xComponent.allocatedKindValue
			}
		} else {
			component.unapplyAllocated
		}
		/* Retrieve components */
		val components = component.components
		
		/* Retrieve MarText model components */
		val xComponents = xComponent.XComponents
		
		/* Retrieve shared components (both UML and MarText models) */
		val preservedComponents = components.map[_component|
			_component -> xComponents.findFirst[_xComponent|
				_component.qualifiedName.equals(_xComponent.qualifiedName)
			] ?: null
		].filter[value.nonNull].toList
		
		/* Retrieve inserted components (MarText model only) */
		val insertedComponents = xComponents.filter[_xComponent |
			components.notExists[_component|
				_component.qualifiedName.equals(_xComponent.qualifiedName)
			]
		].toList
		
		/* Retrieve removed components (UML model only) */
		val removedComponents = components.filter[_component|
			xComponents.notExists[_xComponent|
				_component.qualifiedName.equals(_xComponent.qualifiedName)
			]
		].toList
		
		/* Delete removed components */
		removedComponents.forEach[destroy]
		
		/* Update shared components */
		preservedComponents.forEach[merge]
		
		/* Create inserted components */
		insertedComponents.forEach[component.createComponentFrom(it)]
		
	}

	def private static getNameOrDefault(NamedElement namedElement) {
		Optional.ofNullable(namedElement)
				.map[Strings.emptyToNull(name)]
				.orElse("default_name")
	}
	
	def private static getComponents(Element element) {
		element.ownedElements.filter(Component)
	}
	
	def private static getXComponents(Element element) {
		element.ownedElements.filter(XComponent)
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
	
	def private static isHwComputing(Model model) {
		Optional.ofNullable(model)
				.map[appliedProfiles.exists["HwComputing" == name]]
				.orElse(false)
	}
	
	def private static applyHwComputing(Model model) {
		Optional.ofNullable(model)
				.filter[!hwComputing]
				.ifPresent[applyProfile(profiles.get("HwComputing"))]
	}
	
	def private static isHwProcessor(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.exists["HwProcessor" == name]]
				.orElse(false)
	}
	
	def private static applyHwProcessor(Component component) {
		Optional.ofNullable(component)
				.filter[!component.hwProcessor]
				.ifPresent[applyStereotype(stereotypes.get("HwProcessor"))]
	}
	
	def private static unapplyHwProcessor(Component component) {
		Optional.ofNullable(component)
				.filter[component.hwProcessor]
				.ifPresent[unapplyStereotype(stereotypes.get("HwProcessor"))]
	}
	
	def private static setHwProcessorCores(Component component, int value) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["HwProcessor" == name]]
				.ifPresent[component.setValue(it, "nbCores", value.toString)]
	}
	
	def private static isHwMemory(Model model) {
		Optional.ofNullable(model)
				.map[appliedProfiles.exists["HwMemory" == name]]
				.orElse(false)
	}
	
	def private static applyHwMemory(Model model) {
		Optional.ofNullable(model)
				.filter[!hwMemory]
				.ifPresent[applyProfile(profiles.get("HwMemory"))]
	}
	
	def private static isHwCache(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.exists["HwCache" == name]]
				.orElse(false)
	}
	
	def private static applyHwCache(Component component) {
		Optional.ofNullable(component)
				.filter[!component.hwCache]
				.ifPresent[applyStereotype(stereotypes.get("HwCache"))]
	}
	
	def private static unapplyHwCache(Component component) {
		Optional.ofNullable(component)
				.filter[component.hwCache]
				.ifPresent[unapplyStereotype(stereotypes.get("HwCache"))]
	}
	
	def private static setHwCacheLevel(Component component, int value) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["HwCache" == name]]
				.ifPresent[component.setValue(it, "level", value.toString)]
	}

	def private static isAlloc(Model model) {
		Optional.ofNullable(model)
				.map[appliedProfiles.exists["Alloc" == name]]
				.orElse(false)
	}

	def private static applyAlloc(Model model) {
		Optional.ofNullable(model)
				.filter[!alloc]
				.ifPresent[applyProfile(profiles.get("Alloc"))]
	}
	
	def private static isAllocated(Component component) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.exists["Allocated" == name]]
				.orElse(false)
	}
	
	def private static applyAllocated(Component component) {
		Optional.ofNullable(component)
				.filter[!allocated]
				.ifPresent[applyStereotype(stereotypes.get("Allocated"))]
	}
	
	def private static unapplyAllocated(Component component) {
		Optional.ofNullable(component)
				.filter[component.allocated]
				.ifPresent[unapplyStereotype(stereotypes.get("Allocated"))]
	}
	
	def private static setAllocatedKind(Component component, AllocationEndKind value) {
		Optional.ofNullable(component)
				.map[appliedStereotypes.findFirst["Allocated" == name]]
				.ifPresent[component.setValue(it, "kind", value.toString)]
	}
	
		
	def private static <T> notExists(Iterable<T> iterable, Function1<? super T, Boolean> predicate) {
		return !IteratorExtensions.exists(iterable.iterator(), predicate);
	}

}
	