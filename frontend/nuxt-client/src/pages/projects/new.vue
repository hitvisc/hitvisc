<template>
  <div>
    <div class="page-header d-print-none pb-4">
      <div class="container-xl">
        <div class="row g-2 align-items-center">
          <div class="col">
            <div class="page-pretitle">
              {{ $t('section') }}
            </div>

            <h2 class="page-title">
              {{ $t('features.projects') }}
            </h2>
          </div>
        </div>
      </div>
    </div>

    <div class="container-xl">
      <div class="row">
        <form
          class="col-12"
          @submit.prevent="() => onSubmit()"
        >
          <div
            id="project-creator-accordion"
            class="accordion"
          >
            <projects-create-form-step
              :step="1"
              :current-step="currentStep"
              :done="lastApprovedStep >= 1"
              @collapse="onCollapse(1)"
            >
              <div class="mb-3">
                <label class="form-label required">{{ $t('projects.creator.name') }}</label>

                <input
                  v-model="name"
                  type="text"
                  class="form-control"
                  :class="{
                    'is-invalid': errors.name,
                  }"
                  autocomplete="off"
                />

                <x-error-message
                  v-if="errors.name"
                  :message="errors.name"
                  class="invalid-feedback"
                />
              </div>

              <div class="mb-3">
                <label class="form-label">{{ $t('projects.typeOfUseLabel') }}</label>

                <select
                  v-model="typeOfUse"
                  class="form-control"
                  autocomplete="off"
                >
                  <option
                    v-for="option in typeOfUseOptions"
                    :key="option.value"
                    :value="option.value"
                  >
                    {{ option.label }}
                  </option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label">{{ $t('projects.creator.description') }}</label>

                <textarea
                  v-model="description"
                  type="text"
                  class="form-control"
                  rows="3"
                  :class="{
                    'is-invalid': errors.description,
                  }"
                  autocomplete="off"
                />

                <x-error-message
                  v-if="errors.description"
                  :message="errors.description"
                  class="invalid-feedback"
                />
              </div>

              <div class="mb-3">
                <label class="form-label required">{{ $t('projects.creator.target') }}</label>

                <select
                  v-model="target"
                  class="form-control"
                  :class="{
                    'is-invalid': errors.target,
                  }"
                  autocomplete="off"
                >
                  <option
                    v-for="option in targetsOptions"
                    :key="option.value"
                    :value="option.value"
                  >
                    {{ option.label }}
                  </option>
                </select>

                <x-error-message
                  v-if="errors.target"
                  :message="errors.target"
                  class="invalid-feedback"
                />
              </div>

              <div class="mb-3">
                <label class="form-label required">{{
                  $t('projects.creator.ligandsLibrary')
                }}</label>

                <select
                  v-model="ligand"
                  class="form-control"
                  :class="{
                    'is-invalid': errors.ligand,
                  }"
                  autocomplete="off"
                >
                  <option
                    v-for="option in ligandsOptions"
                    :key="option.value"
                    :value="option.value"
                  >
                    {{ option.label }}
                  </option>
                </select>

                <x-error-message
                  v-if="errors.ligand"
                  :message="errors.ligand"
                  class="invalid-feedback"
                />
              </div>

              <div class="step-buttons">
                <button
                  type="button"
                  class="btn btn-primary"
                  @click="onNext(1)"
                >
                  {{ t('projects.creator.next') }}
                </button>
              </div>
            </projects-create-form-step>

            <projects-create-form-step
              :step="2"
              :current-step="currentStep"
              :done="lastApprovedStep >= 2"
              @collapse="onCollapse(2)"
            >
              <div class="mb-3">
                <label class="form-check form-check-inline">
                  <input
                    v-model="application.id"
                    class="form-check-input"
                    type="radio"
                    :value="ApplicationType.AutoDockVina"
                  />
                  <span class="form-check-label">
                    {{ t(`projects.creator.applications.${ApplicationType.AutoDockVina}`) }}
                  </span>
                </label>
                <label class="form-check form-check-inline">
                  <input
                    v-model="application.id"
                    class="form-check-input"
                    type="radio"
                    :value="ApplicationType.CmDock"
                  />
                  <span class="form-check-label">
                    {{ t(`projects.creator.applications.${ApplicationType.CmDock}`) }}
                  </span>
                </label>
              </div>

              <div class="mb-3">
                <label class="form-label required">
                  {{ t('projects.creator.molecularDockingConfiguration') }}
                </label>

                <div v-if="application.id === ApplicationType.AutoDockVina">
                  <div>
                    <div class="mb-2">
                      <label class="form-check form-check-inline">
                        <input
                          v-model="autoDockVinaOptions.inputType"
                          class="form-check-input"
                          type="radio"
                          :value="AutoDockVinaProtocolSource.Manual"
                        />
                        <span class="form-check-label">
                          {{ t('projects.creator.enterManually') }}
                        </span>
                      </label>
                      <label class="form-check form-check-inline">
                        <input
                          v-model="autoDockVinaOptions.inputType"
                          class="form-check-input"
                          type="radio"
                          :value="AutoDockVinaProtocolSource.File"
                        />
                        <span class="form-check-label">
                          {{ t('projects.creator.loadFile') }}
                        </span>
                      </label>
                    </div>

                    <div
                      v-if="autoDockVinaOptions.inputType === AutoDockVinaProtocolSource.Manual"
                      class="row px-4"
                    >
                      <div class="col-6">
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.centerOfGridSpace') }}
                          </label>
                          <div class="row">
                            <div class="col-4">
                              <div class="input-group">
                                <span class="input-group-text">X</span>
                                <input
                                  v-model="gridSpaceCenterX"
                                  type="number"
                                  step="0.1"
                                  class="form-control"
                                  :class="{
                                    'is-invalid':
                                      errors['application.autoDockVinaOptions.gridSpaceCenter.x'],
                                  }"
                                  autocomplete="off"
                                />
                              </div>
                            </div>
                            <div class="col-4">
                              <div class="input-group">
                                <span class="input-group-text">Y</span>
                                <input
                                  v-model="gridSpaceCenterY"
                                  type="number"
                                  step="0.1"
                                  class="form-control"
                                  :class="{
                                    'is-invalid':
                                      errors['application.autoDockVinaOptions.gridSpaceCenter.y'],
                                  }"
                                  autocomplete="off"
                                />
                              </div>
                            </div>
                            <div class="col-4">
                              <div class="input-group">
                                <span class="input-group-text">Z</span>
                                <input
                                  v-model="gridSpaceCenterZ"
                                  type="number"
                                  step="0.1"
                                  class="form-control"
                                  :class="{
                                    'is-invalid':
                                      errors['application.autoDockVinaOptions.gridSpaceCenter.z'],
                                  }"
                                  autocomplete="off"
                                />
                              </div>
                            </div>
                          </div>
                        </div>

                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.dimensionsOfGridSpace') }}
                          </label>
                          <div class="row">
                            <div class="col-4">
                              <div class="input-group">
                                <span class="input-group-text">X</span>
                                <input
                                  v-model="gridSpaceDimensionsX"
                                  type="number"
                                  step="0.1"
                                  class="form-control"
                                  :class="{
                                    'is-invalid':
                                      errors[
                                        'application.autoDockVinaOptions.gridSpaceDimensions.x'
                                      ],
                                  }"
                                  autocomplete="off"
                                />
                              </div>
                            </div>
                            <div class="col-4">
                              <div class="input-group">
                                <span class="input-group-text">Y</span>
                                <input
                                  v-model="gridSpaceDimensionsY"
                                  type="number"
                                  step="0.1"
                                  class="form-control"
                                  :class="{
                                    'is-invalid':
                                      errors[
                                        'application.autoDockVinaOptions.gridSpaceDimensions.y'
                                      ],
                                  }"
                                  autocomplete="off"
                                />
                              </div>
                            </div>
                            <div class="col-4">
                              <div class="input-group">
                                <span class="input-group-text">Z</span>
                                <input
                                  v-model="gridSpaceDimensionsZ"
                                  type="number"
                                  step="0.1"
                                  class="form-control"
                                  :class="{
                                    'is-invalid':
                                      errors[
                                        'application.autoDockVinaOptions.gridSpaceDimensions.z'
                                      ],
                                  }"
                                  autocomplete="off"
                                />
                              </div>
                            </div>
                          </div>
                        </div>

                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.exhaustiveness') }}
                          </label>
                          <input
                            v-model="exhaustiveness"
                            type="number"
                            step="1"
                            class="form-control"
                            :class="{
                              'is-invalid':
                                errors['application.autoDockVinaOptions.exhaustiveness'],
                            }"
                            autocomplete="off"
                          />
                        </div>

                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.numberOfModes') }}
                          </label>
                          <input
                            v-model="numberOfModes"
                            type="number"
                            step="1"
                            class="form-control"
                            :class="{
                              'is-invalid': errors['application.autoDockVinaOptions.numberOfModes'],
                            }"
                            autocomplete="off"
                          />
                        </div>

                        <div>
                          <label class="form-label">
                            {{ t('projects.creator.energyRange') }}
                          </label>
                          <input
                            v-model="energyRange"
                            type="number"
                            step="0.1"
                            class="form-control"
                            :class="{
                              'is-invalid': errors['application.autoDockVinaOptions.energyRange'],
                            }"
                            autocomplete="off"
                          />
                        </div>
                      </div>
                    </div>
                  </div>

                  <div
                    v-show="autoDockVinaOptions.inputType === 'file'"
                    class="px-4"
                  >
                    <input
                      type="file"
                      :disabled="isUploadingAutoDockVinaProtocolFile"
                      class="form-control"
                      :class="{
                        'is-invalid':
                          errors['application.autoDockVinaOptions.file'] ||
                          !!autoDockVinaProtocolFileUploadError,
                      }"
                      @change="handleAutoDockVinaFile"
                    />

                    <span
                      v-if="isUploadingAutoDockVinaProtocolFile"
                      class="input-icon-addon"
                    >
                      <div class="spinner-border spinner-border-sm text-secondary" />
                    </span>

                    <x-error-message
                      v-if="errors['application.autoDockVinaOptions.file']"
                      :message="errors['application.autoDockVinaOptions.file']"
                      class="invalid-feedback"
                    />
                    <x-error-message
                      v-if="autoDockVinaProtocolFileUploadError"
                      :message="autoDockVinaProtocolFileUploadError"
                      class="invalid-feedback"
                    />
                  </div>
                </div>

                <div v-if="application.id === ApplicationType.CmDock">
                  <div class="mb-2">
                    <label
                      v-if="false"
                      class="form-check form-check-inline"
                    >
                      <input
                        v-model="cmDockOptions.inputType"
                        class="form-check-input"
                        type="radio"
                        :value="CmDockProtocolSource.ManualSpheres"
                      />
                      <span class="form-check-label">
                        {{ t('projects.creator.enterManually2Sphere') }}
                      </span>
                    </label>
                    <label
                      v-if="false"
                      class="form-check form-check-inline"
                    >
                      <input
                        v-model="cmDockOptions.inputType"
                        class="form-check-input"
                        type="radio"
                        :value="CmDockProtocolSource.ManualLigand"
                      />
                      <span class="form-check-label">
                        {{ t('projects.creator.enterManuallyReferenceLigand') }}
                      </span>
                    </label>
                    <label class="form-check form-check-inline">
                      <input
                        v-model="cmDockOptions.inputType"
                        class="form-check-input"
                        type="radio"
                        :value="CmDockProtocolSource.File"
                      />
                      <span class="form-check-label">
                        {{ t('projects.creator.loadFiles') }}
                      </span>
                    </label>
                  </div>

                  <div
                    v-if="cmDockOptions.inputType === CmDockProtocolSource.ManualSpheres"
                    class="row px-4"
                  >
                    <div class="col-6">
                      <fieldset class="form-fieldset">
                        <label class="form-label mb-3">
                          {{ t('projects.creator.cavityMappingRegion') }}
                        </label>

                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.radius') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.radius"
                            type="number"
                            step="0.1"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.smallSphereRadius') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.smallSphereRadius"
                            type="number"
                            step="0.1"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.maximumCavities') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.maximumCavities"
                            type="number"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.minimalVolume') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.minimalVolume"
                            type="number"
                            step="0.1"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.volumeIncrement') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.volumeIncrement"
                            type="number"
                            step="0.1"
                            class="form-control"
                          />
                        </div>
                      </fieldset>
                    </div>

                    <div class="col-6">
                      <div class="mb-3">
                        <label class="form-label">
                          {{ t('projects.creator.center') }}
                        </label>
                        <div class="row">
                          <div class="col-4">
                            <div class="input-group">
                              <span class="input-group-text">X</span>
                              <input
                                v-model="cmDockOptions.center.x"
                                type="number"
                                step="0.1"
                                class="form-control"
                                autocomplete="off"
                              />
                            </div>
                          </div>
                          <div class="col-4">
                            <div class="input-group">
                              <span class="input-group-text">Y</span>
                              <input
                                v-model="cmDockOptions.center.y"
                                type="number"
                                step="0.1"
                                class="form-control"
                                autocomplete="off"
                              />
                            </div>
                          </div>
                          <div class="col-4">
                            <div class="input-group">
                              <span class="input-group-text">Z</span>
                              <input
                                v-model="cmDockOptions.center.z"
                                type="number"
                                step="0.1"
                                class="form-control"
                                autocomplete="off"
                              />
                            </div>
                          </div>
                        </div>
                      </div>

                      <div class="mb-3">
                        <label class="form-label">
                          {{ t('projects.creator.largeSphereRadius') }}
                        </label>
                        <input
                          v-model="cmDockOptions.largeSphereRadius"
                          type="number"
                          step="0.1"
                          class="form-control"
                        />
                      </div>

                      <div>
                        <label class="form-label">
                          {{ t('projects.creator.gridStep') }}
                        </label>
                        <input
                          v-model="cmDockOptions.gridStep"
                          type="number"
                          step="0.1"
                          class="form-control"
                        />
                      </div>
                    </div>
                  </div>

                  <div
                    v-show="cmDockOptions.inputType === CmDockProtocolSource.ManualLigand"
                    class="row px-4"
                  >
                    <div class="col-6">
                      <fieldset class="form-fieldset">
                        <label class="form-label mb-3">
                          {{ t('projects.creator.cavityMappingRegion') }}
                        </label>

                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.radius') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.radius"
                            type="number"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.smallSphereRadius') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.smallSphereRadius"
                            type="number"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.maximumCavities') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.maximumCavities"
                            type="number"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.minimalVolume') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.minimalVolume"
                            type="number"
                            class="form-control"
                          />
                        </div>
                        <div class="mb-3">
                          <label class="form-label">
                            {{ t('projects.creator.volumeIncrement') }}
                          </label>
                          <input
                            v-model="cmDockOptions.cavityMappingRegion.volumeIncrement"
                            type="number"
                            class="form-control"
                          />
                        </div>
                      </fieldset>
                    </div>

                    <div class="col-6">
                      <div>
                        <label class="form-label">
                          {{ t('projects.creator.uploadReferenceLigand') }}
                        </label>

                        <input
                          type="file"
                          class="form-control"
                          :class="{
                            'is-invalid':
                              errors['application.cmDockOptions.ligandFile'] ||
                              !!cmDockReferenceLigandFileUploadError,
                          }"
                          @change="handleCmDockLigandFile"
                        />

                        <span
                          v-if="isUploadingCmDockReferenceLigandFile"
                          class="input-icon-addon"
                        >
                          <div class="spinner-border spinner-border-sm text-secondary" />
                        </span>

                        <x-error-message
                          v-if="errors['application.cmDockOptions.ligandFile']"
                          :message="errors['application.cmDockOptions.ligandFile']"
                          class="invalid-feedback"
                        />
                        <x-error-message
                          v-if="cmDockReferenceLigandFileUploadError"
                          :message="cmDockReferenceLigandFileUploadError"
                          class="invalid-feedback"
                        />
                      </div>
                    </div>
                  </div>

                  <div
                    v-show="cmDockOptions.inputType === CmDockProtocolSource.File"
                    class="px-4"
                  >
                    <div class="mb-3">
                      <label class="form-label">
                        {{ t('projects.creator.cmDockSystemDefinitionFile') }}
                        (*.prm)
                      </label>

                      <input
                        type="file"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            errors['application.cmDockOptions.protocolFile'] ||
                            !!cmDockProtocolFileUploadError,
                        }"
                        @change="handleCmDockProtocolFile"
                      />

                      <span
                        v-if="isUploadingCmDockProtocolFile"
                        class="input-icon-addon"
                      >
                        <div class="spinner-border spinner-border-sm text-secondary" />
                      </span>

                      <x-error-message
                        v-if="errors['application.cmDockOptions.protocolFile']"
                        :message="errors['application.cmDockOptions.protocolFile']"
                        class="invalid-feedback"
                      />
                      <x-error-message
                        v-if="cmDockProtocolFileUploadError"
                        :message="cmDockProtocolFileUploadError"
                        class="invalid-feedback"
                      />
                    </div>

                    <div class="mb-3">
                      <label class="form-label">
                        {{ t('projects.creator.cmDockSiteParamsFile') }}
                        (*.as)
                      </label>

                      <input
                        type="file"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            errors['application.cmDockOptions.siteParamsFile'] ||
                            !!cmDockSiteParamsFileUploadError,
                        }"
                        @change="handleCmDockSiteParamsFile"
                      />

                      <span
                        v-if="isUploadingCmDockSiteParamsFile"
                        class="input-icon-addon"
                      >
                        <div class="spinner-border spinner-border-sm text-secondary" />
                      </span>

                      <x-error-message
                        v-if="errors['application.cmDockOptions.siteParamsFile']"
                        :message="errors['application.cmDockOptions.siteParamsFile']"
                        class="invalid-feedback"
                      />
                      <x-error-message
                        v-if="cmDockSiteParamsFileUploadError"
                        :message="cmDockSiteParamsFileUploadError"
                        class="invalid-feedback"
                      />
                    </div>

                    <div>
                      <label class="form-label">
                        {{ t('projects.creator.cmDockFilterParamsFile') }}
                        (*.ptc)
                      </label>

                      <input
                        type="file"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            errors['application.cmDockOptions.filterParamsFile'] ||
                            !!cmDockFilterParamsFileUploadError,
                        }"
                        @change="handleCmDockFilterParamsFile"
                      />

                      <span
                        v-if="isUploadingCmDockFilterParamsFile"
                        class="input-icon-addon"
                      >
                        <div class="spinner-border spinner-border-sm text-secondary" />
                      </span>

                      <x-error-message
                        v-if="errors['application.cmDockOptions.filterParamsFile']"
                        :message="errors['application.cmDockOptions.filterParamsFile']"
                        class="invalid-feedback"
                      />
                      <x-error-message
                        v-if="cmDockFilterParamsFileUploadError"
                        :message="cmDockFilterParamsFileUploadError"
                        class="invalid-feedback"
                      />
                    </div>
                  </div>
                </div>
              </div>

              <div class="step-buttons">
                <button
                  type="button"
                  class="btn btn-primary"
                  :disabled="lastApprovedStep < 1"
                  @click="onNext(2)"
                >
                  {{ t('projects.creator.next') }}
                </button>
                <button
                  type="button"
                  class="btn btn-ghost-secondary"
                  @click="onPrevious(2)"
                >
                  {{ t('projects.creator.back') }}
                </button>
              </div>
            </projects-create-form-step>

            <projects-create-form-step
              :step="3"
              :current-step="currentStep"
              :done="lastApprovedStep >= 3"
              @collapse="onCollapse(3)"
            >
              <div class="row">
                <div class="col-6">
                  <fieldset class="form-fieldset mb-4">
                    <label class="form-label">
                      {{ t('projects.creator.hitSelectionCriterion') }}
                    </label>

                    <div class="input-group mb-3">
                      <label class="input-group-text">
                        <input
                          v-model="parametersHitsType"
                          class="form-check-input radio-left"
                          type="radio"
                          :value="HitSelectionCriterion.BindingEnergy"
                        />
                        {{ t(`projects.creator.${HitSelectionCriterion.BindingEnergy}`) }}
                      </label>
                      <input
                        v-model="parametersHitsBindingEnergy"
                        max="0"
                        step="0.1"
                        type="number"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            parametersHitsType === HitSelectionCriterion.BindingEnergy &&
                            errors['parameters.hits.bindingEnergy'],
                        }"
                      />
                      <x-error-message
                        v-if="
                          parametersHitsType === HitSelectionCriterion.BindingEnergy &&
                          errors['parameters.hits.bindingEnergy']
                        "
                        :message="errors['parameters.hits.bindingEnergy']"
                        class="invalid-feedback"
                      />
                    </div>

                    <div class="input-group">
                      <label class="input-group-text">
                        <input
                          v-model="parametersHitsType"
                          class="form-check-input radio-left"
                          type="radio"
                          :value="HitSelectionCriterion.LigandEfficiency"
                        />
                        {{ t(`projects.creator.${HitSelectionCriterion.LigandEfficiency}`) }}
                      </label>
                      <input
                        v-model="parametersHitsLigandEfficiency"
                        max="0"
                        step="0.001"
                        type="number"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            parametersHitsType === HitSelectionCriterion.LigandEfficiency &&
                            errors['parameters.hits.ligandEfficiency'],
                        }"
                      />
                      <x-error-message
                        v-if="
                          parametersHitsType === HitSelectionCriterion.LigandEfficiency &&
                          errors['parameters.hits.ligandEfficiency']
                        "
                        :message="errors['parameters.hits.ligandEfficiency']"
                        class="invalid-feedback"
                      />
                    </div>
                  </fieldset>

                  <div v-if="false" class="mb-3">
                    <label class="form-check">
                      <input
                        v-model="parametersNotifyMeOfFoundHits"
                        class="form-check-input"
                        type="checkbox"
                      />
                      <span class="form-check-label">
                        {{ t('projects.creator.notifyMeOfFoundHits') }}
                      </span>
                    </label>

                    <label class="form-check">
                      <input
                        v-model="parametersNotifyMeCompletionOf"
                        class="form-check-input"
                        type="checkbox"
                      />
                      <span class="form-check-label">
                        {{ t('projects.creator.notifyMeCompletionOf') }}
                        <input
                          v-model="parametersCompletedLigandsPercent"
                          min="0"
                          max="100"
                          step="1"
                          type="number"
                          class="form-control form-control-sm d-inline"
                          :class="{
                            'is-invalid':
                              parametersNotifyMeCompletionOf &&
                              errors['parameters.completedLigandsPercent'],
                          }"
                          style="width: 80px"
                        />
                        {{ t('projects.creator.percentLigands') }}
                      </span>
                      <x-error-message
                        v-if="
                          parametersNotifyMeCompletionOf &&
                          errors['parameters.completedLigandsPercent']
                        "
                        :message="errors['parameters.completedLigandsPercent']"
                        class="invalid-feedback"
                      />
                    </label>
                  </div>
                </div>

                <div class="col-6">
                  <fieldset class="form-fieldset">
                    <label class="form-label">
                      {{ t('projects.creator.stoppingCriterion') }}
                    </label>

                    <div class="input-group mb-3">
                      <label class="input-group-text">
                        <input
                          v-model="parametersStopType"
                          class="form-check-input radio-left"
                          type="radio"
                          :value="StoppingCriterion.PercentOfCheckedLigands"
                        />
                        {{ t(`projects.creator.${StoppingCriterion.PercentOfCheckedLigands}`) }}
                      </label>
                      <input
                        v-model="parametersStopPercentOfCheckedLigands"
                        min="0"
                        max="100"
                        step="1"
                        type="number"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            parametersStopType === StoppingCriterion.PercentOfCheckedLigands &&
                            errors['parameters.stop.percentOfCheckedLigands'],
                        }"
                      />
                      <x-error-message
                        v-if="
                          parametersStopType === StoppingCriterion.PercentOfCheckedLigands &&
                          errors['parameters.stop.percentOfCheckedLigands']
                        "
                        :message="errors['parameters.stop.percentOfCheckedLigands']"
                        class="invalid-feedback"
                      />
                    </div>

                    <div class="input-group mb-3">
                      <label class="input-group-text">
                        <input
                          v-model="parametersStopType"
                          class="form-check-input radio-left"
                          type="radio"
                          :value="StoppingCriterion.NumberOfFoundHits"
                        />
                        {{ t(`projects.creator.${StoppingCriterion.NumberOfFoundHits}`) }}
                      </label>
                      <input
                        v-model="parametersStopNumberOfFoundHits"
                        type="number"
                        min="0"
                        step="1"
                        :class="{
                          'is-invalid':
                            parametersStopType === StoppingCriterion.NumberOfFoundHits &&
                            errors['parameters.stop.numberOfFoundHits'],
                        }"
                        class="form-control"
                      />
                      <x-error-message
                        v-if="
                          parametersStopType === StoppingCriterion.NumberOfFoundHits &&
                          errors['parameters.stop.numberOfFoundHits']
                        "
                        :message="errors['parameters.stop.numberOfFoundHits']"
                        class="invalid-feedback"
                      />
                    </div>

                    <div class="input-group">
                      <label class="input-group-text">
                        <input
                          v-model="parametersStopType"
                          class="form-check-input radio-left"
                          type="radio"
                          :value="StoppingCriterion.PercentOfHitsAmongLigands"
                        />
                        {{ t(`projects.creator.${StoppingCriterion.PercentOfHitsAmongLigands}`) }}
                      </label>
                      <input
                        v-model="parametersStopPercentOfHitsAmongLigands"
                        min="0"
                        max="100"
                        step="1"
                        type="number"
                        class="form-control"
                        :class="{
                          'is-invalid':
                            parametersStopType === StoppingCriterion.PercentOfHitsAmongLigands &&
                            errors['parameters.stop.percentOfHitsAmongLigands'],
                        }"
                      />
                      <x-error-message
                        v-if="
                          parametersStopType === StoppingCriterion.PercentOfHitsAmongLigands &&
                          errors['parameters.stop.percentOfHitsAmongLigands']
                        "
                        :message="errors['parameters.stop.percentOfHitsAmongLigands']"
                        class="invalid-feedback"
                      />
                    </div>
                  </fieldset>
                </div>
              </div>

              <div class="mb-3">
                <label
                  v-for="type in ResourcesType"
                  :key="type"
                  class="form-check"
                >
                  <input
                    v-model="resourcesType"
                    class="form-check-input"
                    type="radio"
                    :value="type"
                  />
                  <span class="form-check-label">
                    {{
                      t('projects.creator.resourcesNumberOfNodes', {
                        type: t(`projects.creator.resourcesType.${type}`),
                        count: computationalNodesCount[type],
                      })
                    }}
                  </span>
                </label>
              </div>

              <div class="step-buttons">
                <button
                  type="button"
                  class="btn btn-primary"
                  :disabled="lastApprovedStep < 2"
                  @click="onNext(3)"
                >
                  {{ t('projects.creator.next') }}
                </button>
                <button
                  type="button"
                  class="btn btn-ghost-secondary"
                  @click="onPrevious(3)"
                >
                  {{ t('projects.creator.back') }}
                </button>
              </div>
            </projects-create-form-step>

            <projects-create-form-step
              :step="4"
              :current-step="currentStep"
              :done="lastApprovedStep >= 4"
              @collapse="onCollapse(4)"
            >
              <p>
                <strong> {{ t('projects.creator.name') }}: </strong>
                {{ name }}
              </p>
              <p>
                <strong> {{ t('projects.typeOfUseLabel') }}: </strong>
                {{ t('projects.typeOfUse.' + typeOfUse) }}
              </p>
              <p>
                <strong> {{ t('projects.creator.description') }}: </strong>
                {{ description }}
              </p>
              <p>
                <strong> {{ t('projects.creator.target') }}: </strong>
                {{ targetLabels[target] }}
              </p>
              <p>
                <strong> {{ t('projects.creator.ligandsLibrary') }}: </strong>
                {{ ligandLabels[ligand] }}
              </p>
              <p>
                <strong> {{ t('projects.creator.application') }}: </strong>
                {{ t('projects.creator.applications.' + application.id) }}
              </p>
              <p>
                <strong> {{ t('projects.creator.hitSelectionCriterion') }}: </strong>
                {{ t(`projects.creator.${parametersHitsType}`) }}
              </p>
              <p>
                <strong> {{ t('projects.creator.stoppingCriterion') }}: </strong>
                {{ t(`projects.creator.${parametersStopType}`) }}
              </p>
              <p>
                <strong> {{ t('projects.creator.computationalResources') }}: </strong>
                {{
                  t('projects.creator.resourcesNumberOfNodes', {
                    type: t(`projects.creator.resourcesType.${resourcesType}`),
                    count: computationalNodesCount[resourcesType],
                  })
                }}
              </p>

              <div class="step-buttons">
                <button
                  type="button"
                  class="btn btn-success"
                  :disabled="lastApprovedStep !== 3"
                  @click="() => onSubmit()"
                >
                  {{ t('projects.creator.start') }}
                </button>
                <button
                  type="button"
                  class="btn btn-ghost-secondary"
                  :disabled="lastApprovedStep !== 3"
                  @click="() => onDelay()"
                >
                  {{ t('projects.creator.save') }}
                </button>
              </div>
            </projects-create-form-step>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import axios from 'axios';
import { z } from 'zod';
import { toTypedSchema } from '@vee-validate/zod';
import { useField, useForm } from 'vee-validate';
import { TargetCardDto } from '~/app-modules/library/clients/dto/target.dto';
import { LibraryCardDto } from '~/app-modules/library/clients/dto/library.dto';
import { HostClient } from '~/app-modules/resources/clients/host.client';
import { ApplicationType } from '~/app-modules/library/enums/ApplicationType';
import { ResourcesType } from '~/app-modules/library/enums/ResourcesType';
import { HitSelectionCriterion } from '~/app-modules/projects/enums/HitSelectionCriterion';
import { StoppingCriterion } from '~/app-modules/projects/enums/StoppingCriterion';
import { SearchService } from '~/app-modules/projects/services/search.service';
import { createSearchDto, ExampleSearchDto } from '~/app-modules/projects/clients/dto/search.dto';
import { getSchemasIntersection } from '~/app-modules/core/utils/helpers';
import { TargetService } from '~/app-modules/library/services/target.service';
import { LibraryService } from '~/app-modules/library/services/library.service';
import { TypeOfUse } from '~/app-modules/core/enums/TypeOfUse';
import { UsersStoreProvider } from '~/app-modules/users/stores/users.store';
import { parseUploadFileErrorMessage } from '~/app-modules/core/helpers/files';
import { CmDockProtocolSource } from '~/app-modules/projects/enums/CmDockProtocolSource';
import { AutoDockVinaProtocolSource } from '~/app-modules/projects/enums/AutoDockVinaProtocolSource';
import { EntityState } from '~/app-modules/core/enums/EntityState';
import { HostUsageType } from '~/app-modules/resources/enums/HostUsageType';

const { currentUser } = useIOC(UsersStoreProvider).getStore();

const { t } = useI18n();

const currentStep = ref(1);
const lastApprovedStep = ref(0);

const computationalNodesCount = reactive<{ [type: HostUsageType]: number }>({
  [HostUsageType.Test]: 0,
  [HostUsageType.Private]: 0,
  [HostUsageType.Public]: 0,
});

const typeOfUseOptions = Object.values(TypeOfUse).map((value) => ({
  value,
  label: t(`projects.typeOfUse.${value}`),
}));

const hostClient = useIOC(HostClient);
const targetService = useIOC(TargetService);
const ligandCollectionService = useIOC(LibraryService);

const targets: Ref<TargetCardDto[]> = ref([]);
const targetLabels = computed(() =>
  targets.value.reduce((acc: { [id: string]: string }, item) => {
    acc[item.id] = `${item.name} (${t('library.author')}: ${item.authors})`;
    return acc;
  }, {}),
);
const targetsOptions = computed(() =>
  targets.value.map((item) => ({
    value: item.id,
    label: targetLabels.value[item.id],
  })),
);

const ligands: Ref<LibraryCardDto[]> = ref([]);
const ligandLabels = computed(() =>
  ligands.value.reduce((acc: { [id: string]: string }, item) => {
    acc[item.id] = `${item.name} (${t('library.author')}: ${item.authors})`;
    return acc;
  }, {}),
);
const ligandsOptions = computed(() =>
  ligands.value.map((item) => ({
    value: item.id,
    label: ligandLabels.value[item.id],
  })),
);

fetchData();

async function fetchData() {
  await Promise.all([fetchTargets(), fetchLigandCollections(), fetchResourcesCount()]);
}

async function fetchTargets() {
  try {
    targets.value = await targetService.getSearchReadyTargets();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка получения мишеней');
    } else {
      throw error;
    }
  }
}

async function fetchLigandCollections() {
  try {
    ligands.value = await ligandCollectionService.getSearchReadyLibraries();
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка получения библиотек лигандов');
    } else {
      throw error;
    }
  }
}

async function fetchResourcesCount() {
  try {
    const info = await hostClient.getResourcesCount();
    for (const usageType in computationalNodesCount) {
      computationalNodesCount[usageType] = info[usageType];
    }
  } catch (error) {
    if (axios.isAxiosError(error)) {
      useToast().warning('Ошибка получения информации по вычислительным узлам');
    } else {
      throw error;
    }
  }
}

const detailsSchema = computed(() =>
  z.object({
    name: z
      .string({ required_error: t('validation.required') })
      .min(1, { message: t('validation.required') }),
    description: z
      .string({ required_error: t('validation.required') })
      .max(2000, { message: t('validation.maxLength', { maxLength: 2000 }) }),
    target: z.number({ required_error: t('validation.required') }),
    ligand: z.number({ required_error: t('validation.required') }),
  }),
);

const xyzCoordinateSchema = z.object({
  x: z.number({ required_error: t('validation.required') }),
  y: z.number({ required_error: t('validation.required') }),
  z: z.number({ required_error: t('validation.required') }),
});

const applicationSchema = computed(() =>
  z
    .object({
      application: z.object({
        id: z.nativeEnum(ApplicationType),
        autoDockVinaOptions: z
          .object({
            inputType: z.nativeEnum(AutoDockVinaProtocolSource),
            file: z.string({ required_error: t('validation.required') }).nullable(),
            gridSpaceCenter: xyzCoordinateSchema,
            gridSpaceDimensions: xyzCoordinateSchema,
            exhaustiveness: z.number({ required_error: t('validation.required') }),
            numberOfModes: z.number({ required_error: t('validation.required') }),
            energyRange: z.number({ required_error: t('validation.required') }),
          })
          .optional(),
        cmDockOptions: z
          .object({
            inputType: z.nativeEnum(CmDockProtocolSource),
            protocolFile: z.string({ required_error: t('validation.required') }).nullable(),
            siteParamsFile: z.string({ required_error: t('validation.required') }).nullable(),
            filterParamsFile: z.string({ required_error: t('validation.required') }).nullable(),
            cavityMappingRegion: z.object({
              radius: z.number({ required_error: t('validation.required') }),
              smallSphereRadius: z.number({ required_error: t('validation.required') }),
              maximumCavities: z.number({ required_error: t('validation.required') }),
              minimalVolume: z.number({ required_error: t('validation.required') }),
              volumeIncrement: z.number({ required_error: t('validation.required') }),
            }),
            center: xyzCoordinateSchema,
            largeSphereRadius: z.number({ required_error: t('validation.required') }),
            gridStep: z.number({ required_error: t('validation.required') }),
            ligandFile: z.string({ required_error: t('validation.required') }).nullable(),
          })
          .optional(),
      }),
    })
    .superRefine((data, ctx) => {
      if (
        data.application.id === ApplicationType.AutoDockVina &&
        data.application.autoDockVinaOptions?.inputType === AutoDockVinaProtocolSource.File &&
        !data.application.autoDockVinaOptions.file
      ) {
        ctx.addIssue({
          path: ['application.autoDockVinaOptions.file'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
      if (
        data.application.id === ApplicationType.CmDock &&
        data.application.cmDockOptions?.inputType === CmDockProtocolSource.ManualLigand &&
        !data.application.cmDockOptions.ligandFile
      ) {
        ctx.addIssue({
          path: ['application.cmDockOptions.ligandFile'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
      if (
        data.application.id === ApplicationType.CmDock &&
        data.application.cmDockOptions?.inputType === CmDockProtocolSource.File &&
        !data.application.cmDockOptions.protocolFile
      ) {
        ctx.addIssue({
          path: ['application.cmDockOptions.protocolFile'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
      if (
        data.application.id === ApplicationType.CmDock &&
        data.application.cmDockOptions?.inputType === CmDockProtocolSource.File &&
        !data.application.cmDockOptions.siteParamsFile
      ) {
        ctx.addIssue({
          path: ['application.cmDockOptions.siteParamsFile'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
      if (
        data.application.id === ApplicationType.CmDock &&
        data.application.cmDockOptions?.inputType === CmDockProtocolSource.File &&
        !data.application.cmDockOptions.filterParamsFile
      ) {
        ctx.addIssue({
          path: ['application.cmDockOptions.filterParamsFile'],
          code: z.ZodIssueCode.custom,
          message: t('validation.required'),
        });
      }
    }),
);

const parametersSchema = computed(() =>
  z.object({
    parameters: z.object({
      resourcesType: z.nativeEnum(ResourcesType),
      hits: z.object({
        type: z.nativeEnum(HitSelectionCriterion),
        bindingEnergy: z
          .number({ required_error: t('validation.required') })
          .max(0, { message: t('validation.max', { max: 0 }) }),
        ligandEfficiency: z
          .number({ required_error: t('validation.required') })
          .max(0, { message: t('validation.max', { max: 0 }) }),
      }),
      stop: z.object({
        type: z.nativeEnum(StoppingCriterion),
        percentOfCheckedLigands: z
          .number({ required_error: t('validation.required') })
          .min(0, { message: t('validation.min', { min: 0 }) })
          .max(100, { message: t('validation.max', { max: 100 }) })
          .multipleOf(1, { message: t('validation.integerOnly') }),
        numberOfFoundHits: z
          .number({ required_error: t('validation.required') })
          .min(0, { message: t('validation.min', { min: 0 }) })
          .multipleOf(1, { message: t('validation.integerOnly') }),
        percentOfHitsAmongLigands: z
          .number({ required_error: t('validation.required') })
          .min(0, { message: t('validation.min', { min: 0 }) })
          .max(100, { message: t('validation.max', { max: 100 }) })
          .multipleOf(1, { message: t('validation.integerOnly') }),
      }),
      notifyMeOfFoundHits: z.boolean(),
      notifyMeCompletionOf: z.boolean(),
      completedLigandsPercent: z
        .number({ required_error: t('validation.required') })
        .min(0, { message: t('validation.min', { min: 0 }) })
        .max(100, { message: t('validation.max', { max: 100 }) })
        .multipleOf(1, { message: t('validation.integerOnly') }),
    }),
  }),
);

const validationSchema = computed(() =>
  toTypedSchema(
    getSchemasIntersection(detailsSchema.value, applicationSchema.value, parametersSchema.value),
  ),
);

const projectsService = useIOC(SearchService);

const { values, errors, validateField } = useForm({
  validationSchema,
  initialValues: {
    name: '',
    typeOfUse: TypeOfUse.Private,
    description: '',
    application: {
      id: ApplicationType.AutoDockVina,
      autoDockVinaOptions: {
        inputType: AutoDockVinaProtocolSource.File,
        file: null,
        gridSpaceCenter: { x: 0, y: 0, z: 0 },
        gridSpaceDimensions: { x: 15, y: 15, z: 15 },
        exhaustiveness: 8,
        numberOfModes: 3,
        energyRange: 1,
      },
      cmDockOptions: {
        inputType: CmDockProtocolSource.File,
        protocolFile: null,
        siteParamsFile: null,
        filterParamsFile: null,
        cavityMappingRegion: {
          radius: 20,
          smallSphereRadius: 1.5,
          maximumCavities: 2,
          minimalVolume: 100,
          volumeIncrement: 2,
        },
        center: { x: 0, y: 0, z: 0 },
        largeSphereRadius: 4,
        gridStep: 0.5,
        ligandFile: null,
      },
    },
    parameters: {
      resourcesType: ResourcesType.Test,
      hits: {
        type: HitSelectionCriterion.BindingEnergy,
        bindingEnergy: -10,
        ligandEfficiency: -0.25,
      },
      stop: {
        type: StoppingCriterion.PercentOfCheckedLigands,
        percentOfCheckedLigands: 100,
        numberOfFoundHits: 400,
        percentOfHitsAmongLigands: 1,
      },
      notifyMeOfFoundHits: false,
      notifyMeCompletionOf: false,
      completedLigandsPercent: 50,
    },
  },
});

const { value: name } = useField<string>('name');
const { value: typeOfUse } = useField<string>('typeOfUse');
const { value: description } = useField<string>('description');
const { value: target } = useField<number>('target');
const { value: ligand } = useField<number>('ligand');
const { value: application } = useField('application');
const { value: autoDockVinaOptions } = useField('application.autoDockVinaOptions');
const { value: gridSpaceCenterX } = useField('application.autoDockVinaOptions.gridSpaceCenter.x');
const { value: gridSpaceCenterY } = useField('application.autoDockVinaOptions.gridSpaceCenter.y');
const { value: gridSpaceCenterZ } = useField('application.autoDockVinaOptions.gridSpaceCenter.z');
const { value: gridSpaceDimensionsX } = useField(
  'application.autoDockVinaOptions.gridSpaceDimensions.x',
);
const { value: gridSpaceDimensionsY } = useField(
  'application.autoDockVinaOptions.gridSpaceDimensions.y',
);
const { value: gridSpaceDimensionsZ } = useField(
  'application.autoDockVinaOptions.gridSpaceDimensions.z',
);
const { value: exhaustiveness } = useField('application.autoDockVinaOptions.exhaustiveness');
const { value: numberOfModes } = useField('application.autoDockVinaOptions.numberOfModes');
const { value: energyRange } = useField('application.autoDockVinaOptions.energyRange');
const { value: autoDockVinaProtocolFileId } = useField('application.autoDockVinaOptions.file');
const { value: cmDockReferenceLigandFileId } = useField('application.cmDockOptions.ligandFile');
const { value: cmDockProtocolFileId } = useField('application.cmDockOptions.protocolFile');
const { value: cmDockSiteParamsFileId } = useField('application.cmDockOptions.siteParamsFile');
const { value: cmDockFilterParamsFileId } = useField('application.cmDockOptions.filterParamsFile');
const { value: cmDockOptions } = useField('application.cmDockOptions');
const { value: parametersHitsType } = useField('parameters.hits.type');
const { value: parametersHitsBindingEnergy } = useField('parameters.hits.bindingEnergy');
const { value: parametersHitsLigandEfficiency } = useField('parameters.hits.ligandEfficiency');
const { value: parametersStopType } = useField('parameters.stop.type');
const { value: parametersStopPercentOfCheckedLigands } = useField(
  'parameters.stop.percentOfCheckedLigands',
);
const { value: parametersStopNumberOfFoundHits } = useField('parameters.stop.numberOfFoundHits');
const { value: parametersStopPercentOfHitsAmongLigands } = useField(
  'parameters.stop.percentOfHitsAmongLigands',
);
const { value: parametersNotifyMeOfFoundHits } = useField('parameters.notifyMeOfFoundHits');
const { value: parametersNotifyMeCompletionOf } = useField('parameters.notifyMeCompletionOf');
const { value: parametersCompletedLigandsPercent } = useField('parameters.completedLigandsPercent');
const { value: resourcesType } = useField('parameters.resourcesType');

const autoDockVinaProtocolFileUploadError = ref('');
const cmDockReferenceLigandFileUploadError = ref('');
const cmDockProtocolFileUploadError = ref('');
const cmDockSiteParamsFileUploadError = ref('');
const cmDockFilterParamsFileUploadError = ref('');

const isUploadingAutoDockVinaProtocolFile = ref(false);
const isUploadingCmDockReferenceLigandFile = ref(false);
const isUploadingCmDockProtocolFile = ref(false);
const isUploadingCmDockSiteParamsFile = ref(false);
const isUploadingCmDockFilterParamsFile = ref(false);

async function handleAutoDockVinaFile(event: Event & { target: HTMLInputElement }) {
  autoDockVinaProtocolFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    autoDockVinaProtocolFileId.value = null;
    return;
  }
  try {
    isUploadingAutoDockVinaProtocolFile.value = true;
    autoDockVinaProtocolFileId.value = await projectsService.uploadAutoDockVinaProtocolFile(file);
  } catch (error) {
    autoDockVinaProtocolFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingAutoDockVinaProtocolFile.value = false;
  }
}

async function handleCmDockLigandFile(event: Event & { target: HTMLInputElement }) {
  cmDockReferenceLigandFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    cmDockReferenceLigandFileId.value = null;
    return;
  }
  try {
    isUploadingCmDockReferenceLigandFile.value = true;
    cmDockReferenceLigandFileId.value = await projectsService.uploadCmDockReferenceLigandFile(file);
  } catch (error) {
    cmDockReferenceLigandFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingCmDockReferenceLigandFile.value = false;
  }
}

async function handleCmDockProtocolFile(event: Event & { target: HTMLInputElement }) {
  cmDockProtocolFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    cmDockProtocolFileId.value = null;
    return;
  }
  try {
    isUploadingCmDockProtocolFile.value = true;
    cmDockProtocolFileId.value = await projectsService.uploadCmDockProtocolFile(file);
  } catch (error) {
    cmDockProtocolFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingCmDockProtocolFile.value = false;
  }
}

async function handleCmDockSiteParamsFile(event: Event & { target: HTMLInputElement }) {
  cmDockSiteParamsFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    cmDockSiteParamsFileId.value = null;
    return;
  }
  try {
    isUploadingCmDockSiteParamsFile.value = true;
    cmDockSiteParamsFileId.value = await projectsService.uploadCmDockSiteParamsFile(file);
  } catch (error) {
    cmDockSiteParamsFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingCmDockSiteParamsFile.value = false;
  }
}

async function handleCmDockFilterParamsFile(event: Event & { target: HTMLInputElement }) {
  cmDockFilterParamsFileUploadError.value = '';
  const file = event.target.files?.[0];
  if (!file) {
    cmDockFilterParamsFileId.value = null;
    return;
  }
  try {
    isUploadingCmDockFilterParamsFile.value = true;
    cmDockFilterParamsFileId.value = await projectsService.uploadCmDockFilterParamsFile(file);
  } catch (error) {
    cmDockFilterParamsFileUploadError.value = parseUploadFileErrorMessage(error, t);
  } finally {
    isUploadingCmDockFilterParamsFile.value = false;
  }
}

const detailsFields = computed(() => {
  return ['name', 'description', 'target', 'ligand'];
});

const applicationFields = computed(() => {
  if (application.value.id === ApplicationType.AutoDockVina) {
    if (application.value.autoDockVinaOptions.inputType === AutoDockVinaProtocolSource.Manual) {
      return [
        'application.autoDockVinaOptions.gridSpaceCenter.x',
        'application.autoDockVinaOptions.gridSpaceCenter.y',
        'application.autoDockVinaOptions.gridSpaceCenter.z',
        'application.autoDockVinaOptions.gridSpaceDimensions.x',
        'application.autoDockVinaOptions.gridSpaceDimensions.y',
        'application.autoDockVinaOptions.gridSpaceDimensions.z',
      ];
    }
    if (application.value.autoDockVinaOptions.inputType === AutoDockVinaProtocolSource.File) {
      return ['application.autoDockVinaOptions.file'];
    }
  }
  if (application.value.id === ApplicationType.CmDock) {
    if (application.value.cmDockOptions.inputType === CmDockProtocolSource.ManualSpheres) {
      return [
        'cmDockOptions.cavityMappingRegion.radius',
        'cmDockOptions.cavityMappingRegion.smallSphereRadius',
        'cmDockOptions.cavityMappingRegion.maximumCavities',
        'cmDockOptions.cavityMappingRegion.minimalVolume',
        'cmDockOptions.cavityMappingRegion.volumeIncrement',
        'cmDockOptions.center',
        'cmDockOptions.largeSphereRadius',
        'cmDockOptions.gridStep',
      ];
    }
    if (application.value.cmDockOptions.inputType === CmDockProtocolSource.ManualLigand) {
      return [
        'cmDockOptions.cavityMappingRegion.radius',
        'cmDockOptions.cavityMappingRegion.smallSphereRadius',
        'cmDockOptions.cavityMappingRegion.maximumCavities',
        'cmDockOptions.cavityMappingRegion.minimalVolume',
        'cmDockOptions.cavityMappingRegion.volumeIncrement',
        'application.cmDockOptions.ligandFile',
      ];
    }
    if (application.value.cmDockOptions.inputType === CmDockProtocolSource.File) {
      return [
        'application.cmDockOptions.protocolFile',
        'application.cmDockOptions.siteParamsFile',
        'application.cmDockOptions.filterParamsFile',
      ];
    }
  }
  return [];
});

const parametersFields = computed(() => {
  const fields = ['parameters.resourcesType'];
  if (parametersHitsType.value === HitSelectionCriterion.BindingEnergy) {
    fields.push('parameters.hits.bindingEnergy');
  }
  if (parametersHitsType.value === HitSelectionCriterion.LigandEfficiency) {
    fields.push('parameters.hits.ligandEfficiency');
  }
  if (parametersStopType.value === StoppingCriterion.PercentOfCheckedLigands) {
    fields.push('parameters.stop.percentOfCheckedLigands');
  }
  if (parametersStopType.value === StoppingCriterion.NumberOfFoundHits) {
    fields.push('parameters.stop.numberOfFoundHits');
  }
  if (parametersStopType.value === StoppingCriterion.PercentOfHitsAmongLigands) {
    fields.push('parameters.stop.percentOfHitsAmongLigands');
  }
  if (parametersNotifyMeCompletionOf.value) {
    fields.push('parameters.completedLigandsPercent');
  }
  return fields;
});

const stepFields = {
  1: detailsFields,
  2: applicationFields,
  3: parametersFields,
};

async function onNext(step: 1 | 2 | 3) {
  let isValid = true;
  for (const field of stepFields[step].value) {
    const { valid } = await validateField(field);
    isValid &&= valid;
  }
  if (isValid) {
    lastApprovedStep.value = step;
    currentStep.value = step + 1;
  }
}

function onPrevious(step: number) {
  currentStep.value = step - 1;
}

function onCollapse(step: number) {
  currentStep.value = step;
}

const onSubmit = async (options = { launch: true }) => {
  const isValid = await validateFields();
  if (!isValid) return;
  try {
    await projectsService.createSearch(getCreateSearchDto(options));
    await useRouter().push('/projects');
  } catch (error) {
    useToast().info(t('inWork.title'));
    if (axios.isAxiosError(error)) {
      useToast().error('Ошибка создания проекта');
    } else {
      throw error;
    }
  }
};

async function onDelay() {
  await onSubmit({ launch: false });
}

function getCreateSearchDto(options: { launch: boolean } = { launch: true }): createSearchDto {
  const autoDockVinaProtocolSource = values.application.autoDockVinaOptions.inputType;
  const autoDockVinaParameters =
    values.application.id === ApplicationType.AutoDockVina
      ? {
          inputType: autoDockVinaProtocolSource,
          protocolFileId:
            autoDockVinaProtocolSource === AutoDockVinaProtocolSource.File
              ? values.application.autoDockVinaOptions.file
              : null,
          centerX: values.application.autoDockVinaOptions.gridSpaceCenter.x,
          centerY: values.application.autoDockVinaOptions.gridSpaceCenter.y,
          centerZ: values.application.autoDockVinaOptions.gridSpaceCenter.z,
          sizeX: values.application.autoDockVinaOptions.gridSpaceDimensions.x,
          sizeY: values.application.autoDockVinaOptions.gridSpaceDimensions.y,
          sizeZ: values.application.autoDockVinaOptions.gridSpaceDimensions.z,
          exhaustiveness: values.application.autoDockVinaOptions.exhaustiveness,
          nmodes: values.application.autoDockVinaOptions.numberOfModes,
          erange: values.application.autoDockVinaOptions.energyRange,
        }
      : null;

  const cmDockProtocolSource = values.application.cmDockOptions.inputType;
  const cmDockParameters =
    values.application.id === ApplicationType.CmDock
      ? {
          inputType: cmDockProtocolSource,
          protocolFileId:
            cmDockProtocolSource === CmDockProtocolSource.File
              ? values.application.cmDockOptions.protocolFile
              : null,
          siteParamsFileId:
            cmDockProtocolSource === CmDockProtocolSource.File
              ? values.application.cmDockOptions.siteParamsFile
              : null,
          filterParamsFileId:
            cmDockProtocolSource === CmDockProtocolSource.File
              ? values.application.cmDockOptions.filterParamsFile
              : null,
          referenceLigandFileId:
            cmDockProtocolSource === CmDockProtocolSource.ManualLigand
              ? values.application.cmDockOptions.ligandFile
              : null,
          cavRadius: values.application.cmDockOptions.cavityMappingRegion.radius,
          smallSphereRadius: values.application.cmDockOptions.cavityMappingRegion.smallSphereRadius,
          maxCav: values.application.cmDockOptions.cavityMappingRegion.maximumCavities,
          minVol: values.application.cmDockOptions.cavityMappingRegion.minimalVolume,
          volInc: values.application.cmDockOptions.cavityMappingRegion.volumeIncrement,
          centerX: values.application.cmDockOptions.center.x,
          centerY: values.application.cmDockOptions.center.y,
          centerZ: values.application.cmDockOptions.center.z,
          largeSphereRadius: values.application.cmDockOptions.largeSphereRadius,
          step: values.application.cmDockOptions.gridStep,
        }
      : null;

  return {
    launch: options.launch,
    name: values.name!,
    typeOfUse: values.typeOfUse,
    description: values.description!,
    targetId: values.target!,
    libraryId: values.ligand!,
    applicationId: values.application!.id!,
    resourcesType: values.parameters.resourcesType!,
    hitSelectionCriterion: values.parameters!.hits!.type!,
    hitSelectionValue: getHitSelectionValue(),
    stoppingCriterion: values.parameters!.stop!.type!,
    stoppingValue: getStoppingValue(),
    notifyMeOfFoundHits: values.parameters.notifyMeOfFoundHits!,
    notifyMeCompletionOf: values.parameters.notifyMeCompletionOf!,
    completedLigandsPercent: values.parameters.notifyMeCompletionOf
      ? values.parameters.completedLigandsPercent
      : null,
    autoDockVinaParameters,
    cmDockParameters,
  };
}

function getHitSelectionValue() {
  switch (values.parameters!.hits!.type) {
    case HitSelectionCriterion.BindingEnergy:
      return values.parameters!.hits!.bindingEnergy!;
    case HitSelectionCriterion.LigandEfficiency:
      return values.parameters!.hits!.ligandEfficiency!;
    default:
      throw new Error(`Unsupported hit selection criterion ${values.parameters!.hits!.type}`);
  }
}

function getStoppingValue() {
  switch (values.parameters!.stop!.type) {
    case StoppingCriterion.NumberOfFoundHits:
      return values.parameters!.stop!.numberOfFoundHits;
    case StoppingCriterion.PercentOfCheckedLigands:
      return values.parameters!.stop!.percentOfCheckedLigands!;
    case StoppingCriterion.PercentOfHitsAmongLigands:
      return values.parameters!.stop!.percentOfHitsAmongLigands!;
    default:
      throw new Error(`Unsupported stopping criterion ${values.parameters!.hits!.type}`);
  }
}

async function validateFields() {
  for (const step in stepFields)
    for (const field of stepFields[step].value) {
      const { valid } = await validateField(field);
      if (!valid) return false;
    }
  return true;
}
</script>

<style lang="scss" scoped>
.accordion-item {
  background: white;

  & + & {
    margin-top: 16px;
    border-top: var(--tblr-accordion-border-width) solid var(--tblr-accordion-border-color);
  }
}

.form-fieldset {
  background: unset;
}

.step-buttons {
  .btn:not(:first-of-type) {
    margin-left: 16px;
  }
}

.radio-left {
  margin-right: 8px;
}
</style>
